//
//  MockProvider.swift
//  Nomosi
//
//  Created by Mario on 12/10/2018.
//

import Foundation

public protocol MockProvider {
    
    var isMockEnabled: Bool { get }
    var mockedData: DataConvertible { get }
    
}

public extension MockProvider {
    
    var isMockEnabled: Bool {
        return true
    }
    
}
