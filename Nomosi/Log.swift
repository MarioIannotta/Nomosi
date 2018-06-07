//
//  Log.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
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
