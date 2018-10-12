//
//  CacheProvider.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

public enum CachePolicy {
    case none
    case inRam(timeout: TimeInterval)
    case onDisk(timeout: TimeInterval)
}

public protocol CacheProvider {
    
    func removeAllCachedResponses(before date: Date)
    
    func loadIfNeeded(request: URLRequest,
                      cachePolicy: CachePolicy,
                      completion: ((_ data: Data?) -> Void))
    
    func storeIfNeeded(request: URLRequest,
                       response: URLResponse,
                       data: Data,
                       cachePolicy: CachePolicy) -> Bool
    
}
