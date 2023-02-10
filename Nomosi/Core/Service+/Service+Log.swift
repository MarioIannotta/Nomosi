//
//  Service+Log.swift
//  Nomosi
//
//  Created by Mario on 15/10/2018.
//

import Foundation

public enum Log: Int {
  
  case none = 0
  case minimal = 1
  case verbose = 2
  
  public func print(_ item: @autoclosure () -> Any, requiredLevel: Log = .minimal) {
    guard rawValue >= requiredLevel.rawValue else { return }
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss:SSS"
    let timestamp = formatter.string(from: Date())
    Swift.print("[\(timestamp)] - ", terminator: "")
    Swift.print(item(), separator: " ", terminator: "\n")
  }
}

extension Service: CustomDebugStringConvertible {
  
  private var urlDebugDescription: String {
    return url?.description ?? "Nil url"
  }
  
  var headersDescription: String {
    let headersDescription = headers.count > 0 ? headers.description : "Empty headers"
    return "Headers: \(headersDescription)"
  }
  
  var bodyDescription: String {
    var bodyDescription = "Empty body"
    if let bodyData = body?.asData,
       let bodyAsString = String(data: bodyData, encoding: .utf8),
       bodyAsString.count > 0 {
      bodyDescription = bodyAsString
    } else if let bodyStream = body?.asBodyStream {
      bodyDescription = "Body stream \(bodyStream.description)"
    }
    return "Body: \(bodyDescription)"
  }
  
  public var debugDescription: String {
    return "\(method.rawValue): \(urlDebugDescription)"
  }
}
