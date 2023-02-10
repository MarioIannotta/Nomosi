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
    lhs.hashValue == rhs.hashValue
  }
  
}
