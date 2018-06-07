//
//  ConcurrentLoader.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

class ConcurrentLoader: Loader {
    
    var policy: LoaderPolicy
    var services: [AnyService]
    
    init(policy: LoaderPolicy, services: [AnyService]) {
        self.policy = policy
        self.services = services
    }
    
    deinit {
        cancelOnGoigRequests()
    }
    
    func load(usingOverlay serviceOverlayView: ServiceOverlayView? = nil,
              completion: @escaping (() -> Void)) {
        let dispatchGroup = DispatchGroup()
        services.forEach { service in
            dispatchGroup.enter()
            service.load(usingOverlay: serviceOverlayView) { [weak self, weak service] error in
                dispatchGroup.leave()
                guard let `self` = self, let service = service else {
                    completion()
                    return
                }
                if self.shouldStopLoader(service: service, error: error) {
                    self.cancelOnGoigRequests()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion()
        }
    }
    
}
