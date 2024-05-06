//
//  URLCache+CacheProvider.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import Foundation

extension URLCache: CacheProvider {
  
  private struct Keys {
    fileprivate static let expirationDateKey = "Nomosi.Service.CacheProvider.expirationDateKey"
  }
  
  public func removeExpiredCachedResponses() {
    // I can't find a way to remove just the expired cached responses
    removeAllCachedResponses()
  }
  
  public func loadIfNeeded(request: URLRequest,
                           cacheID: String,
                           cachePolicy: CachePolicy,
                           completion: ((_ data: Data?) -> Void)) {
    if case .none = cachePolicy {
      completion(nil)
      return
    }
    guard
      let cachedResponse = cachedResponse(for: request),
      let expirationDate = cachedResponse.userInfo?[Keys.expirationDateKey] as? Date
    else {
      completion(nil)
      return
    }
    
    let date = Date()
    if expirationDate < date {
      removeCachedResponse(for: request)
      completion(nil)
    } else {
      completion(cachedResponse.data)
    }
  }
  
  public func storeIfNeeded(request: URLRequest,
                            cacheID: String,
                            response: URLResponse,
                            data: Data,
                            cachePolicy: CachePolicy,
                            completion: ((_ success: Bool) -> Void)) {
    
    var storagePolicy: URLCache.StoragePolicy = .notAllowed
    var cacheTimeout: TimeInterval = -1
    switch cachePolicy {
    case .none:
      return completion(false)
    case let .inRam(ramCacheTimeout):
      cacheTimeout = ramCacheTimeout
      storagePolicy = .allowedInMemoryOnly
    case let .onDisk(diskCacheTimeout):
      cacheTimeout = diskCacheTimeout
      storagePolicy = .allowed
    }
    let expirationDate = Date().addingTimeInterval(cacheTimeout)
    let cachedResponse = CachedURLResponse(response: response,
                                           data: data,
                                           userInfo: [Keys.expirationDateKey: expirationDate],
                                           storagePolicy: storagePolicy)
    storeCachedResponse(cachedResponse, for: request)
    completion(true)
  }
  
  public func removeCachedResponse(request: URLRequest, cacheID: String) {
    removeCachedResponse(for: request)
  }
}
