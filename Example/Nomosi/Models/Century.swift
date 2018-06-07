//
//  Century.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

struct Century: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case objectCount = "objectcount"
        case temporalOrder = "temporalOrder"
        case lastUpdate = "lastupdate"
        case detail = "contains"
    }
    
    struct Detail: Decodable {
        
        let groups: [Group]?
        
    }
    
    let id: Int?
    let name: String?
    let objectCount, temporalOrder: Int?
    let lastUpdate: String?
    let detail: Detail?
    
    var formattedDate: String {
        return lastUpdate?
            .split(separator: "T")
            .first?
            .split(separator: "-")
            .reversed()
            .joined(separator: "/") ?? ""
    }
    
}
