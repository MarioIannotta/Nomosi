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
    
    var urlDebugDescription: String {
        return """
        (absoluteURL: \"\(absoluteURL?.absoluteString ?? "")\",
        basePath: \"\(basePath ?? "")\",
        reltivePath: \"\(relativePath ?? "")\")
        """
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
        }
        return "Body: \(bodyDescription)"
    }
    
    public var debugDescription: String {
        let methodDescription = method.rawValue
        let urlDescription = url?.absoluteString ?? "[INVALID URL: \(urlDebugDescription)]"
        return "\(methodDescription): \(urlDescription)"
    }
    
}
