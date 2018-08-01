//
//  GalleriesGallery.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class GalleriesGallery: HarvardArtMuseumService<GalleriesServiceResponse> {
    
    @discardableResult
    init(nextPageLink: String?, id: Int) {
        if let nextPageURL = URL(string: nextPageLink ?? "") {
            super.init(absoluteURL: nextPageURL)
        } else {
            super.init(resource: "gallery")
            relativePath! += "&floor=\(id)"
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
