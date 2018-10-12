//
//  FloorsService.swift
//  Nomosi_Example
//
//  Created by Mario on 12/10/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

// This service has not deployed yet, we'll use a mock for now
class FloorsService: HarvardArtMuseumService<[Floor]> {
    
    init() {
        super.init(resource: "floors")
        mockProvider = self
    }
    
}

extension FloorsService: MockProvider {
    
    var mockedData: DataConvertible {
        var floors = [[String: AnyHashable]]()
        Array(0..<6).forEach { (floorIndex: Int) in
            floors.append(["name": "Floor \(floorIndex)", "id": floorIndex])
        }
        return floors
    }
    
}

