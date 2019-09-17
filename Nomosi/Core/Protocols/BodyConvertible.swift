//
//  BodyConvertible.swift
//  Nomosi
//
//  Created by Mario on 17/09/2019.
//  Copyright © 2019 Mario Iannotta. All rights reserved.
//

import Foundation

public protocol BodyConvertible: DataConvertible {

    var asBodyStream: InputStream? { get }
    
}

extension BodyConvertible {
    
    public var asData: Data? {
        return nil
    }
    
    public var asBodyStream: InputStream? {
        return nil
    }
    
}
