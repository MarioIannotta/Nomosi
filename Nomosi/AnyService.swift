//
//  AnyService.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

public protocol AnyService: class {
    
    typealias AnyServiceResponseCallback = (_ error: Error?) -> Void
    
    func load(usingOverlay serviceOverlayView: ServiceOverlayView?,
              completion: @escaping AnyServiceResponseCallback)
    
    func cancelRequest()
    
    var id: String { get }
    
}

extension Service: AnyService {
    
    public var id: String {
        return "\(hashValue)"
    }
    
    public func load(usingOverlay serviceOverlayView: ServiceOverlayView? = nil,
                     completion: @escaping (_ error: Error?) -> Void) {
        onCompletion { _, error in
            completion(error)
        }
        load(usingOverlay: serviceOverlayView)
    }
    
    public func cancelRequest() {
        cancel()
    }
    
}
