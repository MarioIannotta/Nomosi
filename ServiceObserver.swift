//
//  ServiceObserver.swift
//  Nomosi
//
//  Created by Mario on 01/07/2018.
//

import Foundation

public protocol ServiceObserver {
    
    func serviceDidStartRequest(_ service: AnyService)
    func serviceDidEndRequest(_ service: AnyService, response: ServiceResponse?, error: Error?)
    
}
