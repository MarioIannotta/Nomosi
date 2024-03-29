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
                      cachePolicy: CachePolicy,
                      completion: ((_ data: Data?) -> Void))
    
    func storeIfNeeded(request: URLRequest,
                       response: URLResponse,
                       data: Data,
                       cachePolicy: CachePolicy,
                       completion: ((_ success: Bool) -> Void))
    
    func removeCachedResponse(request: URLRequest)
    
}

extension Service {
    
    func cacheResponseIfNeeded(request: URLRequest,
                               response: URLResponse?,
                               data: Data?) {
        guard
            let response = response,
            let data = data,
            cachePolicy != CachePolicy.none
            else { return }
        cacheProvider?.storeIfNeeded(
            request: request,
            response: response,
            data: data,
            cachePolicy: self.cachePolicy,
            completion: { success in
                log.print("📦 \(self): storing response in cache with policy \(self.cachePolicy)")
            })
    }
}
