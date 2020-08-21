//
//  RequestsQueue.swift
//  Nomosi
//
//  Created by Mario on 14/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

extension URLRequest {
    
    static private var nomosiOnGoingRequests = [URLRequest]()
    
    func begin() {
        URLRequest.nomosiOnGoingRequests.append(self)
    }
    
    func end() {
        URLRequest.nomosiOnGoingRequests.removeAll(where: { $0._isEqual(to: self) })
    }
    
    var isOnGoing: Bool {
        URLRequest.nomosiOnGoingRequests.contains(where: { $0._isEqual(to: self) })
    }
    
    /**
     We can't use the default implementation defined here
     https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/URLRequest.swift as
     ```
     public static func ==(lhs: URLRequest, rhs: URLRequest) -> Bool {
        return lhs._handle._uncopiedReference().isEqual(rhs._handle._uncopiedReference())
     }
     ```
     */
    private func _isEqual(to request: URLRequest) -> Bool {
        requestID == request.requestID
    }   
}
