//
//  UnitTests.swift
//  UnitTests
//
//  Created by Mario Iannotta on 31/01/21.
//  Copyright © 2021 Mario Iannotta. All rights reserved.
//

import XCTest
import Nomosi

class UnitTests: XCTestCase {

  func testRedunantRequestFromSameQueue() {
    let service = AService()
    let expectation = self.expectation(description: "Wait for the request to finish")
    service
      .load()
      .onCompletion { result in
        switch result {
        case .failure(let error):
          XCTAssert(false, "The service failed with error - \(error)")
        case .success:
          break
        }
        expectation.fulfill()
      }
    for _ in 1...100 {
      let redundantService = AService()
      redundantService
        .load()
        .onCompletion { result in
          switch result {
          case .failure(let error):
            XCTAssertEqual(error, ServiceError.redundantRequest, "The request should be redundant")
          case .success:
            XCTAssert(false, "The service should fail")
          }
        }
    }
    waitForExpectations(timeout: 10, handler: nil)
  }

  func testRedunantRequestFromDifferentQueues() {
    let service = AService()
    let expectation = self.expectation(description: "Wait for the request to finish")
    service
      .load()
      .onCompletion { result in
        switch result {
        case .failure(let error):
          XCTAssert(false, "The service failed with error - \(error)")
        case .success:
          break
        }
        expectation.fulfill()
      }
    for i in 0...100 {
      let dispathQueue = DispatchQueue(label: "UnitTests.testRedunantRequestFromDifferentQueues.queue_\(i)", attributes: .concurrent)
      dispathQueue.async {
        let redundantService = AService()
        redundantService
          .load()
          .onCompletion { result in
            switch result {
            case .failure(let error):
              XCTAssertEqual(error, ServiceError.redundantRequest, "The request should be redundant")
            case .success:
              XCTAssert(false, "The service should fail")
            }
          }
      }
    }
    waitForExpectations(timeout: 10, handler: nil)
  }

  @available(iOS 15.0, *)
  @available(macOS 12.0, *)
  func testAsyncAwaitLoad() {
    let service = AService()
    let expectation = self.expectation(description: "Wait for the request to finish")
    Task {
      do {
        let response = try await service.load()
        print(response)
      } catch {
        XCTAssert(false, "The service failed with error - \(error)")
      }
      expectation.fulfill()
    }
    waitForExpectations(timeout: 10, handler: nil)
  }
}
