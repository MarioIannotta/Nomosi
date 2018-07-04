//
//  ObjectsService.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class ObjectsService: HarvardArtMuseumService<ObjectsServiceResponse> {

    @discardableResult
    init?(nextPage: String?) {
        if let nextPageURL = URL(string: nextPage ?? "") {
            super.init(absoluteURL: nextPageURL)
        } else {
            super.init(resource: "object")
        }
    }
    
}

struct ObjectsServiceResponse: ServiceResponse, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case objects = "records"
        case paginatedServiceInfo = "info"
    }
    
    let objects: [Object]
    let paginatedServiceInfo: PaginatedServiceInfo
    
}
