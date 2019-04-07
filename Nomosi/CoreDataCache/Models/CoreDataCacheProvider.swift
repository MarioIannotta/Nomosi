//
//  URLCache+CacheProvider.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import Foundation

class CoreDataCacheProvider: CacheProvider {
    
    lazy var shared: CoreDataCacheProvider = {
        return CoreDataCacheProvider(databaseName: "CachedResponses")
    }()
    
    private var coreDataManager: CoreDataManager?
    
    init(databaseName: String) {
        coreDataManager = CoreDataManager(name: databaseName)
    }
    
    public func removeAllCachedResponses(before date: Date) {

    }
    
    public func loadIfNeeded(request: URLRequest,
                             cachePolicy: CachePolicy,
                             completion: ((_ data: Data?) -> Void)) {
        
    }
    
    @discardableResult
    public func storeIfNeeded(request: URLRequest,
                              response: URLResponse,
                              data: Data,
                              cachePolicy: CachePolicy) -> Bool {
        return false
    }
    
}
