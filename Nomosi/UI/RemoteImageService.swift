//
//  RemoteImageService.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import Foundation
import UIKit

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
