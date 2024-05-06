//
//  CacheProvider.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

public enum CachePolicy: Equatable {
  case none
  case inRam(timeout: TimeInterval)
  case onDisk(timeout: TimeInterval)
}

public protocol CacheProvider: AnyObject {
  
  func removeExpiredCachedResponses()
  
  func loadIfNeeded(request: URLRequest,
                    cacheID: String,
                    cachePolicy: CachePolicy,
                    completion: ((_ data: Data?) -> Void))
  
  func storeIfNeeded(request: URLRequest,
                     cacheID: String,
                     response: URLResponse,
                     data: Data,
                     cachePolicy: CachePolicy,
                     completion: ((_ success: Bool) -> Void))
  
  func removeCachedResponse(request: URLRequest, cacheID: String)
  
}

extension Service {
  
  func cacheResponseIfNeeded(request: URLRequest,
                             cacheID: String,
                             response: URLResponse?,
                             data: Data?) {
    guard
      let response = response,
      let data = data,
      cachePolicy != CachePolicy.none
    else { return }
    cacheProvider?.storeIfNeeded(
      request: request,
      cacheID: cacheID,
      response: response,
      data: data,
      cachePolicy: self.cachePolicy,
      completion: { success in
        log.print("📦 \(self): storing response in cache with policy \(self.cachePolicy). ID: \(cacheID)")
      })
  }
}
