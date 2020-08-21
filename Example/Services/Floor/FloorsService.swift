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
        self.mockProvider = self
    }
}

extension FloorsService: MockProvider { }

