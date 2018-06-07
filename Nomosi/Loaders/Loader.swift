//
//  Loader.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

enum LoaderPolicy {
    
    typealias ErrorEvaluationClosure = (_ service: AnyService, _ error: Error) -> Bool
    
    case ignoreErrors
    case stopAtFirstError
    case custom(shouldStopAtError: ErrorEvaluationClosure)
    
}

protocol Loader {
    
    var policy: LoaderPolicy { get set }
    var services: [AnyService] { get set }
    
}
    
extension Loader {
    
    func shouldStopLoader(service: AnyService, error: Error?) -> Bool {
        guard let error = error else { return false }
        switch self.policy {
        case .ignoreErrors:
            return false
        case .stopAtFirstError:
            return true
        case .custom(let shouldStopAtError):
            return shouldStopAtError(service, error)
        }
    }
    
    func cancelOnGoigRequests() {
        services.forEach { $0.cancelRequest() }
    }
    
}
