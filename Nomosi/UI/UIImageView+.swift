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
        self.log = .none
    }
    
}

extension UIImage: ServiceResponse { }

extension ServiceResponse where Self: UIImage {
    
    public static func parse(data: Data) throws -> Self? {
        return UIImage(data: data) as? Self
    }
    
}

extension UIImageView {
    
    public struct Placeholder {
        
        var loadingView: UIView?
        var errorView: UIView?
        
        public init(loadingView: UIView?, errorView: UIView?) {
            self.loadingView = loadingView
            self.errorView = errorView
        }
        
        public static func activityIndicator(tintColor: UIColor, errorImage: UIImage) -> Placeholder {
            let activityIndicator = UIActivityIndicatorView(style: .gray)
            activityIndicator.startAnimating()
            activityIndicator.color = tintColor
            let errorView = UIImageView(image: errorImage)
            return Placeholder(loadingView: activityIndicator,
                               errorView: errorView)
        }
        
    }
    
    private struct AssociatedObjectKey {
        static var service = "Nomosi.UIImageView+.service"
        static var placeholder = "Nomosi.UIImageView+.placeholder"
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
    
    private var placeholder: Placeholder? {
        get {
            let settedValue = objc_getAssociatedObject(self, &AssociatedObjectKey.placeholder) as? Placeholder
            return settedValue
        }
        set {
            objc_setAssociatedObject(self,
                                     &AssociatedObjectKey.placeholder,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    public func loadImage(link: String,
                          placeholder: Placeholder? = nil,
                          cachePolicy: Cache.Policy = .none) {
        removeErrorPlaceholderView()
        removeLoadingPlaceholderView()
        service?.cancel()
        addPlaceholderLoadingViewIfNeeded(placeholder: placeholder)
        service = RemoteImageService(link: link, cachePolicy: cachePolicy)
            .load()?
            .onCompletion { [weak self] image, _ in
                self?.removeLoadingPlaceholderView()
                self?.setImageAsyncOnMainThread(image, placeholder: placeholder)
            }
    }
    
    private func addPlaceholderLoadingViewIfNeeded(placeholder: Placeholder?) {
        if let placeholderLoadingView = placeholder?.loadingView {
            self.placeholder = placeholder
            placeholderLoadingView.frame = bounds
            addSubview(placeholderLoadingView)
        }
    }
    
    private func removeLoadingPlaceholderView() {
        placeholder?.loadingView?.removeFromSuperview()
    }
    
    private func addErrorPlaceholderViewIfNeeded() {
        if let placeholderErrorView = placeholder?.errorView, image == nil {
            placeholderErrorView.frame = bounds
            addSubview(placeholderErrorView)
        }
    }
    
    private func removeErrorPlaceholderView() {
        placeholder?.errorView?.removeFromSuperview()
    }
    
    private func setImageAsyncOnMainThread(_ image: UIImage?, placeholder: Placeholder?) {
        DispatchQueue.main.async { [weak self] in
            self?.image = image
            self?.addErrorPlaceholderViewIfNeeded()
        }
    }
    
}
