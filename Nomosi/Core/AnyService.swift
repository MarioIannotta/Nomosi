//
//  AnyService.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

/**
 Type erasure protocol for Service<ServiceResponse>
 */
public protocol AnyService: class {
    
    typealias AnyServiceResponseCallback = (_ error: Error?) -> Void
    
    func load(completion: AnyServiceResponseCallback?)
    
    func addObserver(_ serviceObserver: ServiceObserver)
    
    func cancelRequest()
    
    var lastError: ServiceError? { get }
    
    /**
     It's possible to use this method to check for equality.
     It's not possible to make AnyService: Equatable, because we'll have errors like
     "Protocol 'AnyService' can only be used as a generic constraint because
     it has Self or associated type requirements"
     */
    func isEqual(to service: AnyService) -> Bool
}

extension Service: AnyService {
    
    public func load(completion: AnyServiceResponseCallback?) {
        if let completion = completion {
            onCompletion { _, error in
                completion(error)
            }
        }
        load()
    }
    
    public func addObserver(_ serviceObserver: ServiceObserver) {
        addingObserver(serviceObserver)
    }
    
    public func cancelRequest() {
        cancel()
    }
    
    public var lastError: ServiceError? {
        latestError
    }
    
    public func isEqual(to service: AnyService) -> Bool {
        self == service as? Service
    }
}

/**
 It's not possible to make AnyService Equatable so
 I've re-implemented all the array methods I need here
 */
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
    
    public func contains(_ service: AnyService) -> Bool {
        for currentService in self {
            if currentService.isEqual(to: service) {
                return true
            }
        }
        return false
    }
    
    public mutating func appendIfNotExists(_ service: AnyService) {
        if !contains(service) {
            append(service)
        }
    }
    
    public mutating func remove(_ service: AnyService) {
        guard
            let serviceIndex = index(of: service)
            else { return }
        remove(at: serviceIndex)
    }
    
    public func index(of service: AnyService) -> Int? {
        for (index, currentService) in self.enumerated() {
            if currentService.isEqual(to: service) {
                return index
            }
        }
        return nil
    }
}

extension AnyService {
    
    public func and(_ services: AnyService...) -> [AnyService] {
        var allServices = [self as AnyService]
        allServices.append(contentsOf: services)
        return allServices
    }
}
