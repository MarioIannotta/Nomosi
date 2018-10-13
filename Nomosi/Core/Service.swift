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
    public var body: DataConvertible?
    public var headers: [String: String] = [:]
    public var log: Log = .minimal
    public var timeoutInterval: TimeInterval = 60
    public var cacheProvider: CacheProvider = URLCache.shared
    public var cachePolicy: CachePolicy = .none
    public var queue: DispatchQueue = .main
    public var validStatusCodes: Range<Int>? = 200..<300
    public var mockProvider: MockProvider?
    
    public private (set) var latestResponse: Response?
    public private (set) var latestError: ServiceError?
    
    private var url: URL? {
        if let absoluteURL = absoluteURL {
            return absoluteURL
        } else if let basePath = basePath, !basePath.isEmpty {
            if let relativePath = relativePath {
                return URL(string: basePath+relativePath)
            } else {
                return URL(string: basePath)
            }
        }
        return nil
    }
    
    private var sessionDataTask: URLSessionDataTask?
    
    private var completionCallback: CompletionCallback?
    private var successCallback: SuccessCallback?
    private var failureCallback: FailureCallback?
    private var decorateRequestCallback: DecorateRequestCallback?
    private var hasBeenCancelled = false
    private var serviceObservers = [ServiceObserver]()
    
    public init() { }
    
    @discardableResult
    public func onCompletion(_ callback: @escaping CompletionCallback) -> Self {
        completionCallback = callback
        return self
    }
    
    @discardableResult
    public func onSuccess(_ callback: @escaping SuccessCallback) -> Self {
        successCallback = callback
        return self
    }
    
    @discardableResult
    public func onFailure(_ callback: @escaping FailureCallback) -> Self {
        failureCallback = callback
        return self
    }
    
    @discardableResult
    public func decotateRequest(_ callback: @escaping DecorateRequestCallback) -> Self {
        decorateRequestCallback = callback
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
            .decotateRequest { completion in
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
        sessionDataTask?.cancel()
    }

    @discardableResult
    private func _load() -> Self? {
        hasBeenCancelled = false
        log.print("⬆️ \(self)")
        log.print(headersDescription, requiredLevel: .verbose)
        log.print(bodyDescription, requiredLevel: .verbose)
        serviceObservers.forEach { $0.serviceWillStartRequest(self) }
        
        if let mockedData = getMockedDataIfNeeded() {
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
            !RequestsQueue.isOnGoing(request: request)
            else {
                completeRequest(response: nil, error: .redundantRequest)
                return nil
            }
        
        let decorateRequestCallback = self.decorateRequestCallback ?? { completion in completion(nil) }
        decorateRequestCallback { error in
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
    
    private func getMockedDataIfNeeded() -> Data? {
        guard
            let mockProvider = mockProvider,
            mockProvider.isMockEnabled
            else { return nil }
        return mockProvider.mockedData?.asData
    }
    
    private func loadFromCacheIfNeeded(request: URLRequest) {
        cacheProvider.loadIfNeeded(request: request, cachePolicy: self.cachePolicy) { [weak self] data in
            guard
                let `self` = self
                else { return }
            if let data = data {
                self.log.print("📦 \(self): getting data from cache")
                self.parseDataAndCompleteRequest(data: data)
            } else {
                self.performDataTask(request: request)
            }
        }
    }
    
    private func makeRequest() -> URLRequest? {
        guard
            let url = url,
            url.host != nil
            else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        var allHeaders = [String: String]()
        headers.forEach { allHeaders[$0.key] = $0.value }
        request.allHTTPHeaderFields = allHeaders
        request.httpBody = body?.asData
        request.timeoutInterval = timeoutInterval
        return request
    }
    
    private func performDataTask(request: URLRequest) {
        RequestsQueue.append(request: request)
        sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            RequestsQueue.resolve(request: request)
            let _statusCode = (response as? HTTPURLResponse)?.statusCode
            if
                let validStatusCodes = self.validStatusCodes,
                let statusCode = _statusCode,
                !validStatusCodes.contains(statusCode)
            {
                self.completeRequest(response: nil, error: .invalidStatusCode(statusCode))
                return
            }
            var statusCodeDescription = ""
            if let _statusCode = _statusCode {
                statusCodeDescription = String(_statusCode)
            }
            self.log.print("⬇️ [\(statusCodeDescription)] \(self) - \(data?.count ?? 0) bytes")
            if let error = error {
                if (error as NSError).code == NSURLErrorCancelled {
                    self.completeRequest(response: nil, error: .requestCancelled)
                } else {
                    self.completeRequest(response: nil, error: ServiceError(networkError: error))
                }
                return
            }
            guard
                let data = data,
                let response = response
                else {
                    self.completeRequest(response: nil, error: .emptyResponse)
                    return
            }
            let hasResponseBeenCached = self.cacheProvider.storeIfNeeded(request: request,
                                                                         response: response,
                                                                         data: data,
                                                                         cachePolicy: self.cachePolicy)
            if hasResponseBeenCached {
                self.log.print("📦 \(self): storing response in cache with policy \(self.cachePolicy)")
            }
            self.parseDataAndCompleteRequest(data: data)
        }
        sessionDataTask?.resume()
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
                self.successCallback?(safeResponse)
            }
        } else if let error = error {
            self.log.print("⚠️ \(self): Error \(error)")
            DispatchQueue.main.async {
                self.failureCallback?(error)
            }
        }
        DispatchQueue.main.async {
            self.completionCallback?(response, error)
        }
    }
    
}

extension Service: CustomDebugStringConvertible {
    
    private var urlDebugDescription: String {
        return """
        (absoluteURL: \"\(absoluteURL?.absoluteString ?? "")\",
        basePath: \"\(basePath ?? "")\",
        reltivePath: \"\(relativePath ?? "")\")
        """
    }
    
    public var debugDescription: String {
        let methodDescription = method.rawValue
        let urlDescription = url?.absoluteString ?? "[INVALID URL: \(urlDebugDescription)]"
        return "\(methodDescription): \(urlDescription)"
    }
    
    public var headersDescription: String {
        let headersDescription = headers.count > 0 ? headers.description : "Empty headers"
        return "Headers: \(headersDescription)"
    }
    
    public var bodyDescription: String {
        var bodyDescription = "Empty body"
        if let bodyData = body?.asData,
            let bodyAsString = String(data: bodyData, encoding: .utf8),
            bodyAsString.count > 0 {
            bodyDescription = bodyAsString
        }
        return "Body: \(bodyDescription)"
    }
    
}

extension Service: Hashable {
    
    public var hashValue: Int {
        return """
            \(method.rawValue):
            \(url?.absoluteString ?? "")
            \(headers)
            \(String(data: body?.asData ?? Data(), encoding: .utf8) ?? "")
            """.hashValue
    }
    
    public static func == (lhs: Service<Response>, rhs: Service<Response>) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public static func == (lhs: Service<Response>, rhs: AnyService) -> Bool {
        let rhsAsService = rhs as? Service<Response>
        return lhs == rhsAsService
    }
    
    public static func == (lhs: AnyService, rhs: Service<Response>) -> Bool {
        return rhs == lhs
    }
    
}
