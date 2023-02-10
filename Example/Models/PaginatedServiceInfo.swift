//
//  PaginatedServiceInfo.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation

struct PaginatedServiceInfo: Decodable {
  let totalrecordsperquery, totalrecords, pages, page: Int?
  let next: String?
}

