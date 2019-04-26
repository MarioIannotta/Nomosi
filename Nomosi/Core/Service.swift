//
//  Service.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

open class Service<Response: ServiceResponse> {
    
    public typealias CompletionCallback = (_ response: Response?, _ error: ServiceError?) -> Void
    public typealias SuccessCallback = (_ response: Response) -> Void
    public typealias FailureCallback = (_ error: ServiceError) -> Void
    public typealias DecorateRequestCallback = (@escaping (_ error: ServiceError?) -> Void) -> Void
    
    public var method: Method = .get
    public var absoluteURL: URL?
    public var basePath: String?
    public var relativePath: String?
    public var serviceType: ServiceType = .data
    public var body: DataConvertible?
    public var headers: [String: String] = [:]
    public var log: Log = .minimal
    public var timeoutInterval: TimeInterval = 60
    public weak var cacheProvider: CacheProvider? = URLCache.shared
    public var cachePolicy: CachePolicy = .none
    public var queue: DispatchQueue = .main
    public var validStatusCodes: Range<Int>? = 200..<300
    public weak var mockProvider: MockProvider?
    
    public private (set) var latestResponse: Response?
    public private (set) var latestError: ServiceError?
    
    private var sessionTask: URLSessionTask?
    private var completionCallbacks = ThreadSafeArray<CompletionCallback>()
    private var successCallbacks = ThreadSafeArray<SuccessCallback>()
    private var failureCallbacks = ThreadSafeArray<FailureCallback>()
    private var progressCallbacks = ThreadSafeArray<ProgressCallback>()
    private var decorateRequestCallback: DecorateRequestCallback?
    private var hasBeenCancelled = false
    private var serviceObservers = [ServiceObserver]()
    
    public init() { }
    
    @discardableResult
    public func onCompletion(_ callback: @escaping CompletionCallback) -> Self {
        completionCallbacks.append(callback)
        return self
    }
    
    @discardableResult
    public func onSuccess(_ callback: @escaping SuccessCallback) -> Self {
        successCallbacks.append(callback)
        return self
    }
    
    @discardableResult
    public func onFailure(_ callback: @escaping FailureCallback) -> Self {
        failureCallbacks.append(callback)
        return self
    }
    
    @discardableResult
    public func decorateRequest(_ callback: @escaping DecorateRequestCallback) -> Self {
        decorateRequestCallback = callback
        return self
    }
    
    @discardableResult
    public func onProgress(_ callback: @escaping ProgressCallback) -> Self {
        progressCallbacks.append(callback)
        return self
    }
    
    @discardableResult
    public func addingObserver(_ serviceObserver: ServiceObserver) -> Self {
        serviceObservers.append(serviceObserver)
        return self
    }
    
    @discardableResult
    public func load() -> Self? {
        /*
         The "real" load must be performed with some little delay because it's possible
         to schedule a load before setting all the required callbacks.
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
        queue.asyncAfter(deadline: .now() + 0.01) {
            self._load()
        }
        return self
    }
    
    public func cancel() {
        hasBeenCancelled = true
        sessionTask?.cancel()
    }

    @discardableResult
    private func _load() -> Self? {
        hasBeenCancelled = false
        // if the user has defined a decorateRequestCallback, let's log the request after the decorating
        if self.decorateRequestCallback == nil {
            printFullRequest()
        } else {
            log.print("⏱ \(self): decorating request...", requiredLevel: .verbose)
        }
        serviceObservers.forEach { $0.serviceWillStartRequest(self) }
        
        if let mockedData = mockProvider?.mockedData?.asData {
            log.print("🎭 \(self): getting mocked data")
            parseDataAndCompleteRequest(data: mockedData)
            return self
        }
        
        guard
            let request = makeRequest()
            else {
                completeRequest(response: nil, error: .invalidRequest)
                return nil
            }
        
        guard
            !request.isOnGoing
            else {
                completeRequest(response: nil, error: .redundantRequest)
                return nil
            }
        
        let decorateRequestCallback = self.decorateRequestCallback ?? { completion in completion(nil) }
        decorateRequestCallback { error in
            if self.decorateRequestCallback != nil {
                self.printFullRequest()
            }
            if let error = error {
                self.completeRequest(response: nil, error: error)
                return
            }
            
            /*
             If the request has been cancelled while evaluating the closure `decorateRequestCallback`,
             `hasBeenCancelled` would be true, in that case we should not even start the network request
             */
            guard
                !self.hasBeenCancelled
                else {
                    self.completeRequest(response: nil, error: .requestCancelled)
                    return
                }
            
            /*
             the URLRequest needs to be refreshed since it's possible to change
             url, headers etc in decorateRequestCallback
             */
            guard
                let request = self.makeRequest()
                else {
                    self.completeRequest(response: nil, error: .invalidRequest)
                    return
                }
            
            self.loadFromCacheIfNeeded(request: request)
        }
        
        return self
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
        cacheProvider.loadIfNeeded(request: request, cachePolicy: self.cachePolicy) { [weak self] data in
            guard
                let self = self
                else { return }
            if let data = data {
                self.log.print("📦 \(self): getting data from cache")
                self.parseDataAndCompleteRequest(data: data)
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
        sessionTask = URLSession.shared.dataTask(with: request) { data, response, error in
            request.resolve()
            self.handleCompletedTask(request: request, data: data, response: response, error: error)
        }
        sessionTask?.resume()
    }
    
    private func performUploadTask(request: URLRequest) {
        request.begin()
        let uploadDelegate = UploadDelegate(
            onProgress: { [weak self] progress in
                self?.progressCallbacks.forEach { progressCallback in
                    progressCallback(progress)
                }
            },
            onCompletion: { data, response, error in
                request.resolve()
                self.handleCompletedTask(request: request, data: data, response: response, error: error)
            })
        let session = URLSession(configuration: .default,
                                 delegate: uploadDelegate,
                                 delegateQueue: OperationQueue())
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
        let downloadDelegate = DownloadDelegate(onProgress: nil,
                                                onCompletion: {url, response, error in
                                                    request.resolve()
                                                })
        let session = URLSession(configuration: .default,
                                 delegate: downloadDelegate,
                                 delegateQueue: OperationQueue())
        sessionTask = session.downloadTask(with: request)
        sessionTask?.resume()
        session.finishTasksAndInvalidate()
    }
    
    private func handleCompletedTask(request: URLRequest, data: Data?, response: URLResponse?, error: Error?) {
        let statusCode = (response as? HTTPURLResponse)?.statusCode
        if
            let validStatusCodes = validStatusCodes,
            let statusCode = statusCode,
            !validStatusCodes.contains(statusCode)
        {
            completeRequest(response: nil, error: .invalidStatusCode(statusCode))
            return
        }
        let statusCodeDescription = statusCode.flatMap { String($0) } ?? ""
        log.print("⬇️ [\(statusCodeDescription)] \(self) - \(data?.count ?? 0) bytes")
        if let error = error {
            let isCancelled = (error as NSError).code == NSURLErrorCancelled
            let serviceError: ServiceError = isCancelled ? .requestCancelled : ServiceError(networkError: error)
            completeRequest(response: nil, error: serviceError)
            return
        }
        guard
            let data = data
            else {
                completeRequest(response: nil, error: .emptyResponse)
                return
            }
        cacheResponseIfNeeded(request: request, response: response, data: data)
        parseDataAndCompleteRequest(data: data)
    }
    
    private func parseDataAndCompleteRequest(data: Data) {
        let responsString = String(data: data, encoding: .utf8) ?? "\(data.count) bytes"
        self.log.print("Response: \n\(responsString)", requiredLevel: .verbose)
        do {
            let response = try Response.parse(data: data)
            self.completeRequest(response: response, error: nil)
        } catch let error {
            self.completeRequest(response: nil, error: .cannotParseResponse(error: error))
        }
    }
    
    private func completeRequest(response: Response?, error: ServiceError?) {
        latestResponse = response
        latestError = error
        serviceObservers.forEach { $0.serviceDidEndRequest(self) }
        if let safeResponse = response {
            DispatchQueue.main.async {
                self.successCallbacks.forEach { $0(safeResponse) }
            }
        } else if let error = error {
            self.log.print("⚠️ \(self): Error \(error)")
            DispatchQueue.main.async {
                self.failureCallbacks.forEach { $0(error) }
            }
        }
        DispatchQueue.main.async {
            self.completionCallbacks.forEach { $0(response, error) }
        }
    }
    
}
