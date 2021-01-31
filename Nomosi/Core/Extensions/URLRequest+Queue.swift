//
//  RequestsQueue.swift
//  Nomosi
//
//  Created by Mario on 14/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

extension URLRequest {
    
    static private var nomosiOnGoingRequests = [String: URLRequest]()
    
    func begin() {
        URLRequest.nomosiOnGoingRequests[requestID] = self
    }
    
    func end() {
        URLRequest.nomosiOnGoingRequests.removeValue(forKey: requestID)
    }
    
    var isOnGoing: Bool {
        URLRequest.nomosiOnGoingRequests[requestID] != nil
    }
}
