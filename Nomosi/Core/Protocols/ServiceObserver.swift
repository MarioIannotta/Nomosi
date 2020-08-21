//
//  ServiceObserver.swift
//  Nomosi
//
//  Created by Mario on 01/07/2018.
//

import Foundation

public protocol ServiceObserver {
    
    func serviceWillStartRequest(_ service: AnyService)
    func serviceDidEndRequest(_ service: AnyService)
}

extension ServiceObserver {
    
    func serviceWillStartRequest(_ service: AnyService) { }
    func serviceDidEndRequest(_ service: AnyService) { }
}
