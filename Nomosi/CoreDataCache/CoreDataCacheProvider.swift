//
//  URLCache+CacheProvider.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import UIKit

public class CoreDataCacheProvider: CacheProvider {
    
    public static var shared = CoreDataCacheProvider()
    
    private var coreDataManager: CoreDataManager?
    
    private init() {
        coreDataManager = CoreDataManager(name: "NomosiCoreDataCache")
        removeExpiredCachedResponses()
        observeMemoryWarning()
    }
    
    private func observeMemoryWarning() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeExpiredCachedResponses),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)
    }
    
    @objc
    public func removeExpiredCachedResponses() {
        coreDataManager?.removeExpiredCachedResponses()
    }
    
    public func loadIfNeeded(request: URLRequest,
                             cachePolicy: CachePolicy,
                             completion: ((_ data: Data?) -> Void)) {
        switch cachePolicy {
        case .none:
            completion(nil)
        case .inRam:
            URLCache.shared.loadIfNeeded(request: request, cachePolicy: cachePolicy, completion: completion)
        case .onDisk:
            guard
                let cachedResponse = coreDataManager?.fetchCachedResponse(withIdentifier: request.cacheID)
                else {
                    completion(nil)
                    return
                }
            guard
                cachedResponse.expirationDate > Date()
                else {
                    removeCachedResponse(for: request)
                    completion(nil)
                    return
                }
            completion(cachedResponse.cachedData)
        }
    }
    
    public func storeIfNeeded(request: URLRequest,
                              response: URLResponse,
                              data: Data,
                              cachePolicy: CachePolicy,
                              completion: ((_ success: Bool) -> Void)) {
        switch cachePolicy {
        case .none:
            completion(false)
        case .inRam:
            URLCache.shared.storeIfNeeded(request: request,
                                          response: response,
                                          data: data,
                                          cachePolicy: cachePolicy,
                                          completion: completion)
        case .onDisk(let timeout):
            guard
                let coreDataManager = coreDataManager
                else {
                    completion(true)
                    return
                }
            coreDataManager.newCachedResponse { cachedResponse in
                cachedResponse.id = request.cacheID
                cachedResponse.expirationDate = Date().addingTimeInterval(timeout) as NSDate
                cachedResponse.data = data as NSData
                completion(true)
            }
        }
    }
    
    private func removeCachedResponse(for request: URLRequest) {
        coreDataManager?.removeCacheResponse(withIdentifier: request.cacheID)
    }
    
}
