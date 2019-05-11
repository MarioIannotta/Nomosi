//
//  ServiceRequest.swift
//  Nomosi
//
//  Created by Mario on 16/10/2018.
//

import Foundation

public enum Method {
    case post
    case get
    case custom(value: String)
    
    var rawValue: String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        case let .custom(value):
            return value
        }
    }
}

public enum ServiceType {
    case data
    case upload(content: DataConvertible)
    case uploadFile(url: URL)
    case downloadFile
}

extension Service {
    
    func makeRequest() -> URLRequest? {
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
    
}
