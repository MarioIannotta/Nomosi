//
//  Cache+URLCache.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import Foundation

extension URLCache: Cache {
    
    private struct Keys {
        fileprivate static let expiringDateKey = "Nomosi.Service.Cache.expiringDate"
    }
    
    public func removeAllCachedResponses(before date: Date) {
        removeAllCachedResponses()
    }
    
    public func loadIfNeeded(request: URLRequest,
                             cachePolicy: CachePolicy,
                             completion: ((_ data: Data?) -> Void)) {
        if case .none = cachePolicy {
            completion(nil)
            return
        }
        guard
            let cachedResponse = cachedResponse(for: request),
            let expiringDate = cachedResponse.userInfo?[Keys.expiringDateKey] as? Date
            else {
                completion(nil)
                return
            }
        
        let date = Date()
        if expiringDate < date {
            removeCachedResponse(for: request)
            completion(nil)
        } else {
            completion(cachedResponse.data)
        }
    }
    
    @discardableResult
    public func storeIfNeeded(request: URLRequest,
                              response: URLResponse,
                              data: Data,
                              cachePolicy: CachePolicy) -> Bool {
        
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
        storeCachedResponse(cachedResponse, for: request)
        return true
    }
    
}
