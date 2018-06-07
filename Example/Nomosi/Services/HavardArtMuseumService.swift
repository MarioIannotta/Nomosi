//
//  HavardArtMuseumService.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class HavardArtMuseumService<Response: ServiceResponse>: Service<Response> {
    
    let resource: String
    
    init(absoluteURL: URL) {
        self.resource = ""
        super.init()
        self.absoluteURL = absoluteURL
        commonSetup()
    }
    
    init(resource: String) {
        self.resource = resource
        super.init()
        basePath = "https://api.harvardartmuseums.org/"
        relativePath = resource + "?apikey=19222fd0-6a57-11e8-a0b5-c949d872863d"
        commonSetup()
    }
    
    private func commonSetup() {
        cachePolicy = .onDisk(timeout: 60*5) // 5 minutes persistent cache
    }
    
}
