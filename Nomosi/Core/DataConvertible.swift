//
//  DataConvertible.swift
//  Nomosi
//
//  Created by Mario on 04/10/2018.
//  Copyright © 2018 Mario. All rights reserved.
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

extension String: DataConvertible {
    
    public var asData: Data? {
        return data(using: .utf8)
    }
    
}

extension URL: DataConvertible {
    
    public var asData: Data? {
        return try? Data(contentsOf: self)
    }
    
}

extension DataConvertible where Self: Encodable {
    
    public var asData: Data? {
        let jsonEncoder = JSONEncoder()
        return try? jsonEncoder.encode(self)
    }
    
}
