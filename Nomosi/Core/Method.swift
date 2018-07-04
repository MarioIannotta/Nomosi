//
//  Method.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import Foundation

public enum Method {

    case post
    case get
    case custom(value: String)

    var rawValue: String {
        switch self {
        case .post:
            return "POST"
        case .get:
            return "GET"
        case let .custom(value):
            return value
        }
    }

}
