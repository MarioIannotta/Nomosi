//
//  Service+Hashable.swift
//  Nomosi
//
//  Created by Mario on 15/10/2018.
//

import Foundation

extension Service: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(method.rawValue)
        hasher.combine(url)
        hasher.combine(headers)
        hasher.combine(body?.asData)
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
