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

extension Dictionary: DataConvertible, BodyConvertible {
  
  public var asData: Data? {
    try? JSONSerialization.data(withJSONObject: self, options: [])
  }
}

extension Array: DataConvertible, BodyConvertible {
  
  public var asData: Data? {
    try? JSONSerialization.data(withJSONObject: self, options: [])
  }
}

extension String: DataConvertible, BodyConvertible {
  
  public var asData: Data? {
    data(using: .utf8)
  }
}

extension URL: DataConvertible, BodyConvertible {
  
  public var asData: Data? {
    try? Data(contentsOf: self)
  }
}

extension DataConvertible where Self: Encodable {
  
  public var asData: Data? {
    let jsonEncoder = JSONEncoder()
    return try? jsonEncoder.encode(self)
  }
}

extension BodyConvertible where Self: Encodable {
  
  public var asData: Data? {
    let jsonEncoder = JSONEncoder()
    return try? jsonEncoder.encode(self)
  }
}
