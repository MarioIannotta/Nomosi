//
//  AService.swift
//  UnitTests
//
//  Created by Mario Iannotta on 31/01/21.
//  Copyright © 2021 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

/**
 A mocked remote endpoint:
 ```
 {"success":true}
 ```
 */
class AService: Service<AServiceResponse> {
  override init() {
    super.init()
    url = URL(string: "https://pastebin.com/raw/tdA2qddh")
  }
}

struct AServiceResponse: ServiceResponse, Decodable {
  let success: Bool
}
