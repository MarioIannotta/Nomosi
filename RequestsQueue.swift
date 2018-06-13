//
//  RequestsQueue.swift
//  Nomosi
//
//  Created by Mario on 14/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

class RequestsQueue {
    
    static private var onGoinRequests = [URLRequest]()
    
    static func append(request: URLRequest) {
        onGoinRequests.append(request)
    }
    
    static func resolve(request: URLRequest) {
        onGoinRequests = onGoinRequests.filter { $0 != request}
    }
    
    static func isOnGoing(request: URLRequest) -> Bool {
        return onGoinRequests.index(of: request) != nil
    }
    
}
