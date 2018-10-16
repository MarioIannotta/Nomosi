//
//  Service+Hashable.swift
//  Nomosi
//
//  Created by Mario on 15/10/2018.
//

import Foundation

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
