//
//  DataConvertible.swift
//  KeychainSwift
//
//  Created by Mario on 04/10/2018.
//

import Foundation

public protocol DataConvertible {
    
    var asData: Data? { get }
    
}

extension Dictionary: DataConvertible {
    
    public var asData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    
}

extension Array: DataConvertible {
    
    public var asData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    
}
