//
//  NetworkActivityIndicatorHandler.swift
//  Nomosi
//
//  Created by Mario on 04/07/2018.
//

import UIKit

public struct NetworkActivityIndicatorHandler: ServiceObserver {
    
    public init() { }
    
    public func serviceWillStartRequest(_ service: AnyService) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
    public func serviceDidEndRequest(_ service: AnyService) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}
