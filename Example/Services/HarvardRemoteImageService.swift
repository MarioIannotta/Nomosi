//
//  HarvardRemoteImageService.swift
//  Nomosi_Example
//
//  Created by Mario on 07/10/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import Foundation
import UIKit
import Nomosi

class HarvardRemoteImageService: DefaultRemoteImageService {
  
  override init(link: String) {
    super.init(link: link)
    self.cachePolicy = AppConfig.cachePolicy
    self.validStatusCodes = nil // sometimes we receive empty status codes with valid images ¯\_(ツ)_/¯
  }
}


public typealias RemoteImageService = Service<UIImage>

open class DefaultRemoteImageService: Service<UIImage> {
  
  public init(link: String) {
    super.init()
    self.url = URL(string: link)
  }
}

extension UIImage: ServiceResponse { }

extension ServiceResponse where Self: UIImage {
  
  public static func parse(data: Data) throws -> Self? {
    return UIImage(data: data) as? Self
  }
}


extension UIImageView {
  
  @discardableResult
  public func loadImage<T: RemoteImageService>(service: T) -> T {
    self.image = nil
    service
      .load()
      .onCompletion { [weak self] result in
        switch result {
        case .success(let image):
          self?.image = image
        case .failure:
          self?.image = nil
        }
      }
    return service
  }
  
  @discardableResult
  public func loadImage(link: String,
                        cachePolicy: CachePolicy = .none) -> RemoteImageService {
    let defaultRemoteImageService = DefaultRemoteImageService(link: link)
    return self.loadImage(service: defaultRemoteImageService)
  }
}
