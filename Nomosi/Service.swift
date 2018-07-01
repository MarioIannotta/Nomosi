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
    public typealias ShouldLoadServiceCallback = (@escaping (_ shouldLoadService: Bool) -> Void) -> Void
    
    public var method: Method = .get
    public var absoluteURL: URL?
    public var basePath: String?
    public var relativePath: String?
    public var body: Data?
    public var headers: [String: String] = [:]
    public var log: Log = .minimal
    public var timeoutInterval: TimeInterval = 60
    public var cachePolicy: Cache.Policy = .none
    
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
    private (set)var latestResponse: Response?
    private (set)var latestError: ServiceError?
    
    private var completionCallback: CompletionCallback?
    private var successCallback: SuccessCallback?
    private var failureCallback: FailureCallback?
    private var shouldLoadServiceCallback: ShouldLoadServiceCallback?
    private var canStartDataTask = true
    
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
    public func shouldLoadService(_ callback: @escaping ShouldLoadServiceCallback) -> Self {
        shouldLoadServiceCallback = callback
        return self
    }
    
    @discardableResult
    public func load(usingOverlay serviceOverlayView: ServiceOverlayView? = nil) -> Self? {
        log.print("⬆️ \(self)")
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
        
        Cache.loadIfNeeded(request: request, cachePolicy: cachePolicy) { [weak self] data in
            guard let `self` = self else { return }
            if let data = data {
                log.print("📦 \(self): getting date from cache")
                self.parseReceivedDataAndCompleteRequest(data: data)
                return
            } else {
                self.loadIfNeeded(request: request, usingOverlay: serviceOverlayView)
            }
        }
        return self
    }
    
    private func loadIfNeeded(request: URLRequest,
                              usingOverlay serviceOverlayView: ServiceOverlayView? = nil) {
        guard
            self.canStartDataTask
            else {
                self.completeRequest(response: nil, error: .requestCancelled)
                return
            }
        RequestsQueue.append(request: request)
        serviceOverlayView?.addService()
        let shouldLoadServiceCallback = self.shouldLoadServiceCallback ?? { completion in completion(true) }
        shouldLoadServiceCallback { shouldLoadService in
            if shouldLoadService {
                self.performDataTask(request: request) {
                    self.resolve(request, usingOverlay: serviceOverlayView)
                }
            } else {
                self.resolve(request, usingOverlay: serviceOverlayView)
                self.completeRequest(response: nil, error: .shouldLoadServiceEvaluatedToFalse)
            }
        }
    }
    
    private func resolve(_ request: URLRequest, usingOverlay serviceOverlayView: ServiceOverlayView?) {
        serviceOverlayView?.removeService()
        RequestsQueue.resolve(request: request)
    }

    public func cancel() {
        canStartDataTask = false
        sessionDataTask?.cancel()
    }
    
    private func performDataTask(request: URLRequest, completion: @escaping (() -> Void)) {
        sessionDataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            completion()
            let statusCodeString: String = {
                guard
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    else { return "Invalid stauts code" }
                return String(statusCode)
            }()
            self.log.print("⬇️ [\(statusCodeString)] \(self) - \(data?.count ?? 0) bytes")
            if let error = error {
                // is there a better way to do that?
                if error.localizedDescription == "cancelled" {
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
            let hasResponseBeenCached = Cache.storeIfNeeded(request: request,
                                                            response: response,
                                                            data: data,
                                                            cachePolicy: self.cachePolicy)
            if hasResponseBeenCached {
                self.log.print("📦 \(self): storing response in cache with policy \(self.cachePolicy)")
            }
            self.parseReceivedDataAndCompleteRequest(data: data)
        }
        sessionDataTask?.resume()
    }
    
    private func parseReceivedDataAndCompleteRequest(data: Data) {
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
        latestResponse = response
        latestError = error
         // completionCallback?(response, error) causes a segmentation fault ¯\_(ツ)_/¯
        if let completionCallback = completionCallback {
            DispatchQueue.main.async {
                completionCallback(response, error)
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
        request.httpBody = body
        request.timeoutInterval = timeoutInterval
        return request
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
        return "\(method.rawValue): \(url?.absoluteString ?? "[INVALID URL: \(urlDebugDescription)]")"
    }
    
}

extension Service: Hashable {
    
    public var hashValue: Int {
        return """
            \(method.rawValue):
            \(url?.absoluteString ?? "")
            \(headers)
            \(String(data: body ?? Data(), encoding: .utf8) ?? "")
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
