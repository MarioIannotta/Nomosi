//
//  HarvardRemoteImageService.swift
//  Nomosi_Example
//
//  Created by Mario on 07/10/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

class HarvardRemoteImageService: DefaultRemoteImageService {
    
    override init(link: String) {
        super.init(link: link)
        self.cachePolicy = AppConfig.cachePolicy
        self.validStatusCodes = nil // sometimes we receive empty status codes with valid images ¯\_(ツ)_/¯
    }
    
}
