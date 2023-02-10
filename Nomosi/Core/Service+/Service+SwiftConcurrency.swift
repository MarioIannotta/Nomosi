//
//  Service+SwiftConcurrency.swift
//  Nomosi
//
//  Created by Mario on 10/02/23.
//  Copyright © 2023 Mario Iannotta. All rights reserved.
//

import Foundation

public extension Service {
  
  @available(iOS 13.0, *)
  var anyResults: AsyncStream<(ServiceResult, ResponseSource)> {
    AsyncStream { continuation in
      onAnyCompletion { result, source in
        continuation.yield((result, source))
      }
    }
  }
  
  @available(iOS 13.0, *)
  var anySuccess: AsyncStream<(Response, ResponseSource)> {
    AsyncStream { continuation in
      onAnySuccess { response, source in
        continuation.yield((response, source))
      }
    }
  }
  
  @available(iOS 13.0, *)
  var anyFailure: AsyncStream<(ServiceError, ResponseSource)> {
    AsyncStream { continuation in
      onAnyFailure { error, source in
        continuation.yield((error, source))
      }
    }
  }
}
