//
//  CenturiesService.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class CenturiesService: HarvardArtMuseumService<CenturiesServiceResponse> {
    
    init() {
        super.init(resource: "century")
    }
}

struct CenturiesServiceResponse: ServiceResponse, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case centuries = "records"
    }
    
    let centuries: [Century]
}
