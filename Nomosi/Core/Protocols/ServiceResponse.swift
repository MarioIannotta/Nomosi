//
//  ServiceResponse.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

public protocol ServiceResponse {
  
  static func parse(data: Data) throws -> Self?
}

public extension ServiceResponse where Self: Decodable {
  
  static func parse(data: Data) throws -> Self? {
    let jsonDecoder = JSONDecoder()
    return try jsonDecoder.decode(Self.self, from: data)
  }
}

extension Array: ServiceResponse where Element: Decodable { }

// Usefull for a download service like DownloadService: Service<URL>

extension URL: ServiceResponse {
  
  public static func parse(data: Data) throws -> URL? {
    guard
      let string = String(data: data, encoding: .utf8)
    else {
      return nil
    }
    return URL(string: string)
  }
}
