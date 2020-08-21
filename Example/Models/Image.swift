//
//  Image.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

struct Image: Decodable {
    let height: Int?
    let iiifbaseuri, baseimageurl: String?
    let width: Int?
    let publiccaption: String?
    let idsid, displayorder: Int?
    let copyright: String?
    let imageid: Int?
    let renditionnumber: String?
}
