//
//  Service.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

open class Service<Response: ServiceResponse> {

    public typealias ServiceResult = Result<Response, ServiceError>
    public typealias CompletionClosure = (ServiceResult) -> Void
    public typealias SuccessClosure = (_ response: Response) -> Void
    public typealias FailureClosure = (_ error: ServiceError) -> Void
    public typealias DecorateRequestClosure = (@escaping (_ error: ServiceError?) -> Void) -> Void
    public typealias ShouldRetryClosure = (_ result: ServiceResult, _ retryCount: Int) -> Bool
    public typealias ValidateResponseClosure = (_ response: Response) -> Error?
    
    public var method: Method = .get
    public var url: URL?
    public var serviceType: ServiceType = .data
    public var body: BodyConvertible?
    public var headers: [String: String] = [:]
    public var log: Log = .minimal
    public var timeoutInterval: TimeInterval = 60
    public weak var cacheProvider: CacheProvider? = URLCache.shared
    public var cachePolicy: CachePolicy = .none
    public var queue: DispatchQueue = .main
    public var validStatusCodes: Range<Int>? = 200..<300
    public weak var mockProvider: MockProvider?
    public var sslPinningHandler: SSLPinningHandler?
    
    public private (set) var latestResponse: Response?
    public private (set) var latestError: ServiceError?
    public var decorateRequestClosure: DecorateRequestClosure?
    public var shouldRetryClosure: ShouldRetryClosure?
    public var validateResponseClosure: ValidateResponseClosure?
    
    private var sessionTask: URLSessionTask?
    private var completionClosures = ThreadSafeArray<CompletionClosure>()
    private var successClosures = ThreadSafeArray<SuccessClosure>()
    private var failureClosures = ThreadSafeArray<FailureClosure>()
    private var progressClosures = ThreadSafeArray<ProgressClosure>()
    private var hasBeenCancelled = false
    private var serviceObservers = [ServiceObserver]()
    private var retryCount = 0
    private var loadWorkItem: DispatchWorkItem?
    
    public init() { }
    
    @discardableResult
    public func onCompletion(_ closure: @escaping CompletionClosure) -> Self {
        completionClosures.append(closure)
        load()
        return self
    }
    
    @discardableResult
    public func onSuccess(_ closure: @escaping SuccessClosure) -> Self {
        successClosures.append(closure)
        load()
        return self
    }
    
    @discardableResult
    public func onFailure(_ closure: @escaping FailureClosure) -> Self {
        failureClosures.append(closure)
        load()
        return self
    }
    
    @discardableResult
    public func decorateRequest(_ closure: @escaping DecorateRequestClosure) -> Self {
        decorateRequestClosure = closure
        load()
        return self
    }
    
    @discardableResult
    public func shouldRetry(_ closure: @escaping ShouldRetryClosure) -> Self {
        shouldRetryClosure = closure
        load()
        return self
    }
    
    @discardableResult
    public func validateResponse(_ closure: @escaping ValidateResponseClosure) -> Self {
        validateResponseClosure = closure
        load()
        return self
    }
    
    @discardableResult
    public func onProgress(_ closure: @escaping ProgressClosure) -> Self {
        progressClosures.append(closure)
        load()
        return self
    }
    
    @discardableResult
    public func addingObserver(_ serviceObserver: ServiceObserver) -> Self {
        serviceObservers.append(serviceObserver)
        load()
        return self
    }
    
    @discardableResult
    public func load() -> Self {
        /*
         The "real" load must be performed with some little delay because it's possible
         to schedule a load before setting all the required closures.
         eg:
         ```
         AService()
            .load()
            .addingObserver(anObserve)
            .addingObserver(anotherObserver)
            .decorateRequest { completion in
                completion(something)
            }
            .onSuccess {
                // Do stuff on success
            }
            .onFailure { error in
                // Do stuff on failure
            }
         ```
         In the example above without the delay if the service request is not valid an error
         would be raised before setting the closure to handle the error itself `onFailure {...}`.
         */
        retryCount = 0
        cancelLoadWorkItem()
        let newLoadWorkItem = DispatchWorkItem { self.debouncedLoad() }
        loadWorkItem = newLoadWorkItem
        queue.asyncAfter(deadline: .now() + 0.01, execute: newLoadWorkItem)
        
        return self
    }
    
    public func cancel() {
        cancelLoadWorkItem()
        hasBeenCancelled = true
        sessionTask?.cancel()
    }

    private func debouncedLoad() {
        cancelLoadWorkItem()
        retryCount += 1
        hasBeenCancelled = false
        // if the user has defined a decorateRequestClosure, let's log the request after the decorating
        if self.decorateRequestClosure == nil {
            printFullRequest()
        } else {
            log.print("⏱ \(self): decorating request...", requiredLevel: .verbose)
        }
        serviceObservers.forEach { $0.serviceWillStartRequest(self) }
        
        if let mockedData = mockProvider?.mockedData?.asData {
            log.print("🎭 \(self): getting mocked data")
            parseDataAndValidateRequest(data: mockedData)
            return
        }
        
        guard
            let request = makeRequest()
            else {
                completeRequest(result: .failure(.invalidRequest))
                return
            }
        
        guard
            !request.isOnGoing
            else {
                completeRequest(result: .failure(.redundantRequest))
                return
            }
        
        let decorateRequestCallback = self.decorateRequestClosure ?? { completion in completion(nil) }
        decorateRequestCallback { error in
            if self.decorateRequestClosure != nil {
                self.printFullRequest()
            }
            if let error = error {
                self.completeRequest(result: .failure(error))
                return
            }
            
            /*
             If the request has been cancelled while evaluating the closure `decorateRequestCallback`,
             `hasBeenCancelled` would be true, in that case we should not even start the network request
             */
            guard
                !self.hasBeenCancelled
                else {
                    self.completeRequest(result: .failure(.requestCancelled))
                    return
                }
            
            /*
             the URLRequest needs to be refreshed since it's possible to change
             url, headers etc in decorateRequestCallback
             */
            guard
                let request = self.makeRequest()
                else {
                    self.completeRequest(result: .failure(.invalidRequest))
                    return
                }
            
            self.loadFromCacheIfNeeded(request: request)
        }
    }
    
    private func cancelLoadWorkItem() {
        loadWorkItem?.cancel()
        loadWorkItem = nil
    }
    
    private func printFullRequest() {
        log.print("⬆️ \(self)")
        log.print(headersDescription, requiredLevel: .verbose)
        log.print(bodyDescription, requiredLevel: .verbose)
    }
    
    private func loadFromCacheIfNeeded(request: URLRequest) {
        guard
            let cacheProvider = cacheProvider
            else {
                self.performTask(request: request)
                return
            }
        cacheProvider.loadIfNeeded(request: request, cachePolicy: cachePolicy) { [weak self] data in
            guard
                let self = self
                else { return }
            if let data = data {
                self.log.print("📦 \(self): getting data from cache")
                self.parseDataAndValidateRequest(data: data)
            } else {
                self.performTask(request: request)
            }
        }
    }
    
    private func performTask(request: URLRequest) {
        switch serviceType {
        case .data:
            performDataTask(request: request)
        case .upload,
             .uploadFile:
            performUploadTask(request: request)
        case .downloadFile:
            performDownloadTask(request: request)
        }
    }
    
    private func performDataTask(request: URLRequest) {
        request.begin()
        let session = URLSession(configuration: .default,
                                 delegate: TaskDelegate(sslPinningHandler: sslPinningHandler),
                                 delegateQueue: nil)
        sessionTask = session.dataTask(with: request) { data, response, error in
            request.end()
            self.handleCompletedTask(request: request, data: data, response: response, error: error)
        }
        sessionTask?.resume()
        session.finishTasksAndInvalidate() // the session delegate is retained. More info https://stackoverflow.com/a/49772414
    }
    
    private func makeURLSession(delegate: URLSessionDelegate) -> URLSession {
        URLSession(configuration: .default,
                   delegate: delegate,
                   delegateQueue: OperationQueue())
    }
    
    private func performUploadTask(request: URLRequest) {
        request.begin()
        let uploadDelegate = UploadDelegate(
            onProgress: forwardProgress,
            onCompletion: { data, response, error in
                request.end()
                self.handleCompletedTask(request: request, data: data, response: response, error: error)
            },
            sslPinningHandler: sslPinningHandler)
        let session = makeURLSession(delegate: uploadDelegate)
        switch serviceType {
        case .upload(let content):
            sessionTask = session.uploadTask(with: request, from: content.asData ?? Data())
        case .uploadFile(let url):
            sessionTask = session.uploadTask(with: request, fromFile: url)
        default:
            break
        }
        sessionTask?.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func performDownloadTask(request: URLRequest) {
        request.begin()
        let downloadDelegate = DownloadDelegate(
            onProgress: forwardProgress,
            onCompletion: { url, response, error in
                request.end()
                self.handleCompletedTask(request: request,
                                         data: url.absoluteString.asData,
                                         response: response,
                                         error: error)
            },
            sslPinningHandler: sslPinningHandler)
        let session = makeURLSession(delegate: downloadDelegate)
        sessionTask = session.downloadTask(with: request)
        sessionTask?.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func forwardProgress(_ progress: Progress) {
        progressClosures.forEach { $0(progress) }
    }
    
    private func handleCompletedTask(request: URLRequest, data: Data?, response: URLResponse?, error: Error?) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        if
            let validStatusCodes = validStatusCodes,
            let statusCode = statusCode,
            !validStatusCodes.contains(statusCode)
        {
            completeRequest(result: .failure(.invalidStatusCode(statusCode)))
            return
        }
        let statusCodeDescription = statusCode.flatMap { String($0) } ?? ""
        log.print("⬇️ [\(statusCodeDescription)] \(self) - \(data?.count ?? 0) bytes")
        if let error = error {
            let isCancelled = (error as NSError).code == NSURLErrorCancelled
            let serviceError: ServiceError = isCancelled ? .requestCancelled : ServiceError(networkError: error)
            completeRequest(result: .failure(serviceError))
            return
        }
        guard
            let data = data
            else {
                completeRequest(result: .failure(.emptyResponse))
                return
            }
        cacheResponseIfNeeded(request: request, response: response, data: data)
        parseDataAndValidateRequest(data: data)
    }
    
    private func parseDataAndValidateRequest(data: Data) {
        let responseString = String(data: data, encoding: .utf8) ?? "\(data.count) bytes"
        self.log.print("Response: \n\(responseString)", requiredLevel: .verbose)
        do {
            if let response = try Response.parse(data: data) {
                completeRequest(result: .success(response))
            } else {
                completeRequest(result: .failure(.cannotParseResponse(error: nil)))
            }
        } catch let error {
            completeRequest(result: .failure(.cannotParseResponse(error: error)))
        }
    }
    
    private func completeRequest(result: ServiceResult) {
        let shouldRetry = shouldRetryClosure?(result, retryCount) ?? false
        guard
            !shouldRetry
            else {
                log.print("🔄 \(self): Retrying request")
                self.debouncedLoad()
                return
            }

        var result = result
        switch result {
        case .failure(let error):
            latestError = error
            notifyError(error)
        case .success(let response):
            if let validationError = validateResponseClosure?(response).map(ServiceError.responseValidationFailed) {
                result = .failure(validationError)
                latestError = validationError
                notifyError(validationError)
            } else {
                latestResponse = response
                notifySuccess(response)
            }
        }
        notifyCompletion(result: result)
    }
    
    private func notifyError(_ error: ServiceError) {
        self.log.print("⚠️ \(self): Error \(error)")
        DispatchQueue.main.async {
            self.failureClosures.forEach { $0(error) }
        }
    }
    
    private func notifySuccess(_ response: Response) {
        DispatchQueue.main.async {
            self.successClosures.forEach { $0(response) }
        }
    }
    
    private func notifyCompletion(result: ServiceResult) {
        DispatchQueue.main.async {
            self.completionClosures.forEach { $0(result) }
            self.serviceObservers.forEach { $0.serviceDidEndRequest(self) }
        }
    }
}
