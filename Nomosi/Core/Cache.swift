//
//  Cache.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

private struct Keys {
    fileprivate static let expiringDateKey = "Nomosi.Service.Cache.expiringDate"
}

public struct Cache {
    
    public enum Policy {
        case none
        case inRam(timeout: TimeInterval)
        case onDisk(timeout: TimeInterval)
    }
    
    public static func removeAllCachedResponses() {
        URLCache.shared.removeAllCachedResponses()
    }
    
    static func loadIfNeeded(request: URLRequest,
                             cachePolicy: Cache.Policy,
                             completion: ((_ data: Data?) -> Void)) {
        if case .none = cachePolicy {
            completion(nil)
            return
        }
        guard
            let cachedResponse = URLCache.shared.cachedResponse(for: request),
            let expiringDate = cachedResponse.userInfo?[Keys.expiringDateKey] as? Date
            else {
                completion(nil)
                return
            }
        
        let date = Date()
        if expiringDate < date {
            URLCache.shared.removeCachedResponse(for: request)
            completion(nil)
        } else {
            completion(cachedResponse.data)
        }
    }
    
    @discardableResult
    static func storeIfNeeded(request: URLRequest,
                              response: URLResponse,
                              data: Data,
                              cachePolicy: Cache.Policy) -> Bool {
        
        var storagePolicy: URLCache.StoragePolicy = .notAllowed
        var cacheTimeout: TimeInterval = -1
        switch cachePolicy {
        case .none:
            return false
        case let .inRam(ramCacheTimeout):
            cacheTimeout = ramCacheTimeout
            storagePolicy = .allowedInMemoryOnly
        case let .onDisk(diskCacheTimeout):
            cacheTimeout = diskCacheTimeout
            storagePolicy = .allowed
        }
        let expiringDate = Date().addingTimeInterval(cacheTimeout)
        let cachedResponse = CachedURLResponse(response: response,
                                               data: data,
                                               userInfo: [Keys.expiringDateKey: expiringDate],
                                               storagePolicy: storagePolicy)
        URLCache.shared.storeCachedResponse(cachedResponse, for: request)
        return true
    }
    
}
