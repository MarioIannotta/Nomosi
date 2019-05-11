//
//  HarvardArtMuseumService.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class HarvardArtMuseumService<Response: ServiceResponse>: Service<Response> {
    
    let resource: String
    
    init(url: URL) {
        self.resource = ""
        super.init()
        self.url = url
        commonSetup()
    }
    
    init(resource: String, queryItems: [String: String] = [:]) {
        self.resource = resource
        super.init()
        var urlString = "https://api.harvardartmuseums.org/"
        
        var resourceAndQuery = resource + "?apikey=19222fd0-6a57-11e8-a0b5-c949d872863d"
        for queryItem in queryItems {
            resourceAndQuery += "&\(queryItem.key)=\(queryItem.value)"
        }
        urlString += resourceAndQuery
        url = URL(string: urlString)
        commonSetup()
    }
    
    private func commonSetup() {
        cacheProvider = CoreDataCacheProvider.shared
        cachePolicy = AppConfig.cachePolicy
        log = AppConfig.logLevel
        addingObserver(NetworkActivityIndicatorHandler())
        let oldURL = url
        decorateRequest { [weak self] completion in
            self?.url = AppConfig.isNetworkErrorActive ? URL(string: "http://www.marioiannotta.com") : oldURL
            let idleTimeInterval: TimeInterval = AppConfig.isNetworkRequestDelayEnabled ? 3 : 0
            DispatchQueue.main.asyncAfter(deadline: .now() + idleTimeInterval) {
                completion(nil)
            }
        }
    }
    
}
