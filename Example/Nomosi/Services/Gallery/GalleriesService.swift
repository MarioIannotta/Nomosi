//
//  GalleriesService.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class GalleriesService: HarvardArtMuseumService<GalleriesServiceResponse> {
    
    @discardableResult
    init(nextPageLink: String?, id: Int) {
        if let nextPageURL = URL(string: nextPageLink ?? "") {
            super.init(absoluteURL: nextPageURL)
        } else {
            var queryItems = [String: String]()
            queryItems["floor"] = String(id)
            queryItems["sort"] = "id"
            queryItems["fields"] = "id,name,theme,labeltext".replacingOccurrences(of: ",", with: "%2C")
            super.init(resource: "gallery", queryItems: queryItems)
        }
    }
    
}

struct GalleriesServiceResponse: ServiceResponse, Decodable {
    
    enum CodingKeys: String, CodingKey {
        case galleries = "records"
        case paginatedServiceInfo = "info"
    }
    
    let galleries: [Gallery]
    let paginatedServiceInfo: PaginatedServiceInfo
    
}
