//
//  Gallery.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

struct Gallery: Decodable, Hashable {
    
    private let summaryLenght = 60
    
    var galleryNumber: String
    var name: String
    var id: Int
    var lastUpdate: String
    var floor: Int
    var theme: String?
    var labelText: String?
    var summaryLabelText: String? {
        guard
            let labelText = labelText,
            labelText.count >= summaryLenght
            else {
                return nil
            }
        let substringIndex = labelText.index(labelText.startIndex, offsetBy: summaryLenght)
        var summary = String(labelText[...substringIndex])
        if summary != labelText {
            summary = "\(summary)... [Read more]"
        }
        return summary
    }
    
    enum CodingKeys: String, CodingKey {
        case galleryNumber = "gallerynumber"
        case name = "name"
        case id = "id"
        case lastUpdate = "lastupdate"
        case floor = "floor"
        case theme = "theme"
        case labelText = "labeltext"
    }
    
    // MARK: - Hashable
    
    var hashValue: Int {
        return id
    }
    
}
