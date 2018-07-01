//
//  Loader.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

open class Loader {

    public typealias ErrorEvaluationClosure = (_ service: AnyService, _ error: Error) -> Bool
    
    public enum ErrorPolicy {
        case ignoreErrors
        case stopAtFirstError
        case custom(shouldStopAtError: ErrorEvaluationClosure)
    }
    
    private (set) var errorPolicy: ErrorPolicy
    private (set) var services: [AnyService]
    
    public init(services: [AnyService], errorPolicy: ErrorPolicy) {
        self.errorPolicy = errorPolicy
        self.services = services
    }
    
    deinit {
        cancelOnGoigRequests()
    }
    
    public func load(usingOverlay serviceOverlayView: ServiceOverlayView? = nil,
                     completion: (() -> Void)?) {
        assert(false, "Loader is an abstract class")
    }
    
    public func cancelOnGoigRequests() {
        services.forEach { $0.cancelRequest() }
    }
    
    internal func shouldStopLoader(service: AnyService, error: Error?) -> Bool {
        guard let error = error else { return false }
        switch errorPolicy {
        case .ignoreErrors:
            return false
        case .stopAtFirstError:
            return true
        case .custom(let shouldStopAtError):
            return shouldStopAtError(service, error)
        }
    }
    
}
