//
//  ServiceError.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

public struct ServiceError: LocalizedError {
    
    public struct UserInfo {
        
        public let statusCode: Int?
        public let underlyingError: Error?
        
        fileprivate init(statusCode: Int? = nil, underlyingError: Error? = nil) {
            self.statusCode = statusCode
            self.underlyingError = underlyingError
        }
    }
    
    public static func responseValidationFailed(_ error: Error) -> ServiceError {
        return ServiceError(code: 8,
                            reason: "Error validating service response",
                            userInfo: UserInfo(underlyingError: error))
    }
    public static func invalidStatusCode(_ statusCode: Int?) -> ServiceError {
        return ServiceError(code: 7,
                            reason: "Invalid status code \(String(describing: statusCode))",
                            userInfo: UserInfo(statusCode: statusCode))
    }
    public static var redundantRequest = ServiceError(code: 6, reason: "The same request is already running")
    public static var requestCancelled = ServiceError(code: 5, reason: "The request has been cancelled")
    public static var invalidRequest = ServiceError(code: 4, reason: "Invalid request")
    public static var emptyResponse = ServiceError(code: 3, reason: "Empty response")
    public static func cannotParseResponse(error: Error) -> ServiceError {
        return ServiceError(code: 2,
                            reason: "Can't parse the response",
                            userInfo: UserInfo(underlyingError: error))
    }
    
    public var code: Int
    public var reason: String
    public var userInfo: UserInfo?
    
    public init(code: Int, reason: String, userInfo: UserInfo? = nil) {
        self.code = code
        self.reason = reason
        self.userInfo = userInfo
    }
    
    public init(networkError: Error) {
        self.code = 1
        self.reason = networkError.localizedDescription
        self.userInfo = UserInfo(underlyingError: networkError)
    }
    
    public var errorDescription: String? {
        return "Error \(code) - \(reason)"
    }
    
}

extension ServiceError: Equatable {
    
    public static func == (lhs: ServiceError, rhs: ServiceError) -> Bool {
        return lhs.code == rhs.code
    }
    
}

extension ServiceError: CustomStringConvertible {

    public var description: String {
        return "\(code) - \(reason)"
    }
    
}
