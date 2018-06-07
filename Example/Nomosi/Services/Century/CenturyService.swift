//
//  CenturyService.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class CenturyService: HavardArtMuseumService<Century> {
    
    init(id: Int) {
        super.init(resource: "century/\(id)")
    }
    
}

extension Century: ServiceResponse { }
