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

    init?(galleryID: Int?, nextPageLink: String? = nil) {
        if let nextPageURL = URL(string: nextPageLink ?? "") {
            super.init(absoluteURL: nextPageURL)
        } else {
            var queryItems = [String: String]()
            let fields = "objectid,title,primaryimageurl,century,classification,dateoffirstpageview"
            queryItems["fields"] = fields.replacingOccurrences(of: ",", with: "%2C")
            if let galleryID = galleryID {
                queryItems["gallery"] = String(galleryID)
            }
            queryItems["sort"] = "dateoffirstpageview"
            queryItems["sortorder"] = "desc"
            super.init(resource: "object", queryItems: queryItems)
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
