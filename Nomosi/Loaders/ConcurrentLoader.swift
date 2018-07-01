//
//  ConcurrentLoader.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

open class ConcurrentLoader: Loader {
    
    override public func load(usingOverlay serviceOverlayView: ServiceOverlayView? = nil,
                              completion: (() -> Void)?) {
        let dispatchGroup = DispatchGroup()
        services.forEach { service in
            dispatchGroup.enter()
            service.load(usingOverlay: serviceOverlayView) {  error in
                dispatchGroup.leave()
                if self.shouldStopLoader(service: service, error: error) {
                    self.cancelOnGoigRequests()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion?()
        }
    }
    
}

extension Array where Element == AnyService {
    
    public func concurrentLoad(usingOverlay serviceOverlayView: ServiceOverlayView? = nil,
                               errorPolicy: Loader.ErrorPolicy = .ignoreErrors,
                               completion: (() -> Void)?) {
        ConcurrentLoader(services: self, errorPolicy: errorPolicy)
            .load(usingOverlay: serviceOverlayView,
                  completion: completion)
    }
    
}
