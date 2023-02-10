//
//  ThreadSafeArray.swift
//  Nomosi
//
//  Created by Mario on 26/04/2019.
//

import Foundation

class ThreadSafeArray<Element> {
  
  private let queue = DispatchQueue(label: "com.nomosi.core.threadSafeArrayQueue", attributes: .concurrent)
  private var array = [Element]()
  
  func append( _ element: Element) {
    queue.async(flags: .barrier) {
      self.array.append(element)
    }
  }
  
  func forEach(_ body: (Element) -> Void) {
    queue.sync { self.array.forEach(body) }
  }
}
