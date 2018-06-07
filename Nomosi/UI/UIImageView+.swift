//
//  UIImageView+.swift
//  Nomosi
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

class RemoteImageService: Service<UIImage> {
    
    init(link: String, cachePolicy: Cache.Policy) {
        super.init()
        self.absoluteURL = URL(string: link)
        self.cachePolicy = cachePolicy
    }
    
}

extension UIImage: ServiceResponse { }

extension ServiceResponse where Self: UIImage {
    
    public static func parse(data: Data) throws -> Self? {
        return UIImage(data: data) as? Self
    }
    
}

extension UIImageView {
    
    private struct AssociatedObjectKey {
        static var service = "Nomosi.service"
    }
    
    private var service: RemoteImageService? {
        get {
            let settedValue = objc_getAssociatedObject(self, &AssociatedObjectKey.service) as? RemoteImageService
            return settedValue
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedObjectKey.service,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func loadImage(link: String, cachePolicy: Cache.Policy = .none) {
        service?.cancel()
        service = RemoteImageService(link: link, cachePolicy: cachePolicy)
            .onCompletion { [weak self] image, _ in
                self?.setImageAsyncOnMainThread(image)
            }
            .load()
    }
    
    private func setImageAsyncOnMainThread(_ image: UIImage?) {
        DispatchQueue.main.async { [weak self] in
            self?.image = image
        }
    }
    
}
