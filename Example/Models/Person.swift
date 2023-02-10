//
//  Person.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

struct Person: Decodable {
  let alphasort: String?
  let birthplace: String?
  let name: String?
  let personPrefix: String?
  let personid: Int?
  let gender, role: String?
  let displayorder: Int?
  let culture: String?
  let displaydate, deathplace: String?
  let displayname: String?
}
