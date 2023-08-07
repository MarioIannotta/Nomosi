//
//  Service+TaskDelegate.swift
//  Nomosi
//
//  Created by Mario on 03/10/2019.
//  Copyright © 2019 Mario Iannotta. All rights reserved.
//

import Foundation

class TaskDelegate: NSObject, URLSessionTaskDelegate {
  
  private weak var sslPinningHandler: SSLPinningHandler?
  
  public init(sslPinningHandler: SSLPinningHandler?) {
    self.sslPinningHandler = sslPinningHandler
  }
  
  func urlSession(_ session: URLSession,
                  didReceive challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    guard let sslPinningHandler = sslPinningHandler
    else {
      completionHandler(.performDefaultHandling, nil)
      return
    }
    let configuration = sslPinningHandler.configuration(for: challenge)
    completionHandler(configuration.disposition, configuration.credentials)
  }
}
