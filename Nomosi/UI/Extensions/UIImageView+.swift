//
//  UIImageView+.swift
//  Nomosi
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

extension UIImageView {
    
    @discardableResult
    public func loadImage<T: RemoteImageService>(service: T,
                                                 overlayView: RemoteImageServiceOverlayView? = nil) -> T {
        self.image = nil
        if var overlayView = overlayView {
            overlayView.superview = self
            service.addObserver(overlayView)
        }
        service
            .load()?
            .onCompletion { [weak self] image, _ in
                self?.image = image
            }
        return service
    }
    
    @discardableResult
    public func loadImage(link: String,
                          cachePolicy: CachePolicy = .none,
                          overlayView: RemoteImageServiceOverlayView? = nil) -> RemoteImageService {
        let defaultRemoteImageService = DefaultRemoteImageService(link: link)
        return self.loadImage(service: defaultRemoteImageService,
                              overlayView: overlayView)
    }
    
}
