//
//  SequentialLoader.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

class SequentialLoader: Loader {
    
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
        
        loadNextServiceIfNeeded(usingOverlay: serviceOverlayView) { _ in
            completion()
        }
    }
    
    private func loadNextServiceIfNeeded(atIndex serviceIndex: Int = 0,
                                         usingOverlay serviceOverlayView: ServiceOverlayView?,
                                         completion: @escaping ((_ error: Error?) -> Void)) {
        guard serviceIndex < services.count else {
            completion(nil)
            return
        }
        loadService(services[serviceIndex], usingOverlay: serviceOverlayView) { [weak self] shouldStopRequests, error in
            guard shouldStopRequests else {
                self?.loadNextServiceIfNeeded(atIndex: serviceIndex + 1,
                                             usingOverlay: serviceOverlayView,
                                             completion: completion)
                return
            }
            self?.cancelOnGoigRequests()
            completion(error)
        }
    }
    
    private func loadService(_ service: AnyService,
                             usingOverlay: ServiceOverlayView?,
                             completion: @escaping ((_ shouldStopRequests: Bool, _ error: Error?) -> Void)) {
        service.load(usingOverlay: usingOverlay) { [weak self, weak service] error in
            guard let `self` = self, let service = service else {
                completion(true, error)
                return
            }
            completion(self.shouldStopLoader(service: service, error: error), error)
        }
    }
    
}
