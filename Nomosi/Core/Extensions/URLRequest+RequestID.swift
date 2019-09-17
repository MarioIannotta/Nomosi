//
//  URLCache+CacheProvider.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import Foundation

extension URLRequest {
    
    /**
     This method try to get a unique identifier from url request properties. f(method, url, headers, body) -> id
     Basically the idea is to get all those values as string and sorting them.
     The sort is necessary because the query parameters, the headers and even
     the body (if it's a json dictionary for example) could have a different description
     (based on the current elements order) even with the same data.
     Example:
     - Query parameter: adomain.com/api?a=1&b=2 vs adomain.com/api?b=2&a=1
     - Headers: [a:1, b:2] vs [b:2, a:1]
     - Body: {"a": 1, "b": 2} vs {"b": 2, "a": 1}
     
     Sorthing the final string will generate the same identifier for those kind of requests
     and a collision is highly unlikely.
    */
    var requestID: String {
        return String([httpMethod,
                       url?.absoluteString,
                       allHTTPHeaderFields?.description,
                       String(data: httpBody ?? Data(), encoding: .utf8)]
            .compactMap { $0 }
            .joined()
            .sorted())
    }
    
}
