//
//  AppConfig.swift
//  Nomosi_Example
//
//  Created by Mario on 04/07/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

struct AppConfig {
    
    static var isNetworkErrorActive: Bool = false
    static var slowDownNetworkRequest: Bool = false
    static var cachePolicy: Cache.Policy = .none
    static var logLevel: Log = .minimal
    
}
