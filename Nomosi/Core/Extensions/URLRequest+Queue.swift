//
//  RequestsQueue.swift
//  Nomosi
//
//  Created by Mario on 14/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

extension URLRequest {
  
  private static let queue = DispatchQueue(label: "com.nomosi.core.urlRequestQueue", attributes: .concurrent)
  
  static private var nomosiOnGoingRequests = [String: URLRequest]()
  
  func begin() {
    Self.queue.async(flags: .barrier) {
      URLRequest.nomosiOnGoingRequests[requestID] = self
    }
  }
  
  func end() {
    Self.queue.async(flags: .barrier) {
      URLRequest.nomosiOnGoingRequests.removeValue(forKey: requestID)
    }
  }
  
  var isOnGoing: Bool {
    Self.queue.sync(flags: .barrier) {
      return URLRequest.nomosiOnGoingRequests[requestID] != nil
    }
  }
}
