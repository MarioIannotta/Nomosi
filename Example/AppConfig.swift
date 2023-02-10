//
//  AppConfig.swift
//  Nomosi_Example
//
//  Created by Mario on 04/07/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import Nomosi

struct AppConfig {
  
  struct Keys {
    static let isNetworkErrorActive = "isNetworkErrorActive"
    static let isNetworkRequestDelayEnabled = "isNetworkRequestDelayEnabled"
    static let cachePolicyState = "cachePolicyState"
    static let cachePolicyTimeout = "cachePolicyTimeout"
    static let logLevel = "logLevel"
  }
  
  static var isNetworkErrorActive: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: Keys.isNetworkErrorActive)
    }
    get {
      UserDefaults.standard.bool(forKey: Keys.isNetworkErrorActive)
    }
  }
  
  static var isNetworkRequestDelayEnabled: Bool {
    set {
      UserDefaults.standard.set(newValue, forKey: Keys.isNetworkRequestDelayEnabled)
    }
    get {
      UserDefaults.standard.bool(forKey: Keys.isNetworkRequestDelayEnabled)
    }
  }
  
  static var cachePolicy: CachePolicy {
    set {
      var state: Int = 0
      var timeout: TimeInterval = 0
      switch newValue {
      case .inRam(let _timeout):
        state = 1
        timeout = _timeout
      case .onDisk(let _timeout):
        state = 2
        timeout = _timeout
      default:
        break
      }
      UserDefaults.standard.set(state, forKey: Keys.cachePolicyState)
      UserDefaults.standard.set(timeout, forKey: Keys.cachePolicyTimeout)
    }
    get {
      guard
        let state = UserDefaults.standard.value(forKey: Keys.cachePolicyState) as? Int,
        let timeout = UserDefaults.standard.value(forKey: Keys.cachePolicyTimeout) as? TimeInterval
      else {
        return .inRam(timeout: 30)
      }
      switch state {
      case 1:
        return .inRam(timeout: timeout)
      case 2:
        return .onDisk(timeout: timeout)
      default:
        return .none
      }
    }
  }
  
  static var logLevel: Log {
    set {
      UserDefaults.standard.set(newValue.rawValue, forKey: Keys.logLevel)
    }
    get {
      let storedRawValue = UserDefaults.standard.value(forKey: Keys.logLevel) as? Int ?? -1
      return Log(rawValue: storedRawValue) ?? .minimal
    }
  }
}
