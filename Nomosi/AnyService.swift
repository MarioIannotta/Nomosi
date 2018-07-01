//
//  AnyService.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

/**
 Type erasure protocol for Service
 */
public protocol AnyService: class {
    
    typealias AnyServiceResponseCallback = (_ error: Error?) -> Void
    
    func load(completion: @escaping AnyServiceResponseCallback)
    
    func addObserver(_ serviceObserver: ServiceObserver)
    
    func cancelRequest()
    
}

extension Service: AnyService {
    
    public func load(completion: @escaping (_ error: Error?) -> Void) {
        onCompletion { _, error in
            completion(error)
        }
        load()
    }
    
    public func addObserver(_ serviceObserver: ServiceObserver) {
        addingObserver(serviceObserver)
    }
    
    public func cancelRequest() {
        cancel()
    }
    
}

// MARK: - Syntax sugar dance

extension Array where Element == AnyService {
    
    public func and(_ services: AnyService...) -> [AnyService] {
        var allServices = self
        allServices.append(contentsOf: services)
        return allServices
    }
    
    public func addingObserver(_ serviceObserver: ServiceObserver) -> [AnyService] {
        forEach { $0.addObserver(serviceObserver) }
        return self
    }
    
}

extension AnyService {
    
    public func and(_ services: AnyService...) -> [AnyService] {
        var allServices = [self as AnyService]
        allServices.append(contentsOf: services)
        return allServices
    }
    
}
