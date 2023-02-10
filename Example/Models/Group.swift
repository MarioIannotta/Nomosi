//
//  Group.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

struct Group: Decodable {
  
  private enum CodingKeys: String, CodingKey {
    case name = "name"
    case groupID = "groupId"
  }
  
  let name: String?
  let groupID: Int?
}
