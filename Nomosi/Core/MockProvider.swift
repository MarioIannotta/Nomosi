//
//  MockProvider.swift
//  Nomosi
//
//  Created by Mario on 12/10/2018.
//

import Foundation

public protocol MockProvider {
    
    var isMockEnabled: Bool { get }
    var mockedData: DataConvertible? { get }
    
}

public extension MockProvider {
    
    var isMockEnabled: Bool {
        return true
    }
    
    var mockedData: DataConvertible? {
        guard
            isMockEnabled
            else {
                return nil
            }
        let mockProviderName = String(describing: type(of: self))
        guard
            let path = Bundle.main.path(forResource: mockProviderName, ofType: "mock")
            else {
                return nil
            }
        return URL(fileURLWithPath: path)
    }
    
}
