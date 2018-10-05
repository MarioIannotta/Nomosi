//
//  ServiceError.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

public struct ServiceError: Error, Equatable {
    
    public static func invalidStatusCode(_ statusCode: Int?) -> ServiceError {
        var statusCodeDescription = ""
        if let statusCode = statusCode {
            statusCodeDescription = String(statusCode)
        }
        return ServiceError(code: 8, reason: "The status code \(statusCodeDescription) is invalid")
    }
    public static var redundantRequest = ServiceError(code: 7, reason: "The same request is already running")
    public static var requestCancelled = ServiceError(code: 6, reason: "The request has been cancelled")
    public static var shouldLoadServiceEvaluatedToFalse = ServiceError(code: 5, reason: "should load service callback evaluated to false")
    public static var invalidRequest = ServiceError(code: 4, reason: "The request is not valid")
    public static var emptyResponse = ServiceError(code: 3, reason: "Empty response")
    public static func cannotParseResponse(error: Error) -> ServiceError {
        return ServiceError(code: 2, reason: "Can't parse the response; Error: \(error)")
    }
    
    public var code: Int
    public var reason: String
    
    public init(code: Int, reason: String) {
        self.code = code
        self.reason = reason
    }
    
    public init(networkError: Error) {
        self.code = 1
        self.reason = networkError.localizedDescription
    }
    
}

extension ServiceError: CustomStringConvertible {

    public var description: String {
        return "\(code) - \(reason)"
    }
    
}
