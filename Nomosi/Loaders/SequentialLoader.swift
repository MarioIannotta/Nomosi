//
//  SequentialLoader.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

class SequentialLoader: Loader {
    
    override func load(completion: (() -> Void)?) {
        
        loadNextServiceIfNeeded { _ in
            completion?()
        }
    }
    
    private func loadNextServiceIfNeeded(atIndex serviceIndex: Int = 0,
                                         completion: @escaping ((_ error: Error?) -> Void)) {
        guard
            serviceIndex < services.count
            else {
                completion(nil)
                return
            }
        loadService(services[serviceIndex]) { [weak self] shouldStopRequests, error in
            guard shouldStopRequests else {
                self?.loadNextServiceIfNeeded(atIndex: serviceIndex + 1,
                                             completion: completion)
                return
            }
            self?.cancelOnGoigRequests()
            completion(error)
        }
    }
    
    private func loadService(_ service: AnyService,
                             completion: @escaping ((_ shouldStopRequests: Bool, _ error: Error?) -> Void)) {
        service.load() { [weak self, weak service] error in
            guard let `self` = self, let service = service else {
                completion(true, error)
                return
            }
            completion(self.shouldStopLoader(service: service, error: error), error)
        }
    }
    
}

extension Array where Element == AnyService {
    
    public func sequentialLoad(usingOverlay serviceOverlayView: ServiceObserver? = nil,
                               errorPolicy: Loader.ErrorPolicy = .ignoreErrors,
                               completion: (() -> Void)?) {
        SequentialLoader(services: self, errorPolicy: errorPolicy)
            .load(completion: completion)
    }
    
}
