//
//  ServiceError.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

public struct ServiceError: Error {

    public static var requestCancelled: ServiceError {
        return ServiceError(code: 6, reason: "The request has been cancelled")
    }
    
    public static var shouldLoadServiceEvaluatedToFalse: ServiceError {
        return ServiceError(code: 5, reason: "should load service callback evaluated to false")
    }
    
    public static var invalidRequest: ServiceError {
        return ServiceError(code: 4, reason: "The request is not valid")
    }
    
    public static var emptyResponse: ServiceError {
        return ServiceError(code: 3, reason: "Empty response")
    }
    
    public static func cannotParseResponse(error: Error) -> ServiceError {
        return ServiceError(code: 2, reason: "Can't parse the response; Error: \(error)")
    }
    
    private var code: Int
    private var reason: String
    
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
