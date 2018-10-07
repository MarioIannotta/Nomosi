//
//  RemoteImageServiceOverlayView.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import UIKit

public struct RemoteImageServiceOverlayView: ServiceObserver {
    
    var superview: UIView?
    private var loadingView: UIView
    private var errorView: UIView?
    
    public init(loadingView: UIView, errorView: UIView?) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public static func activityIndicator(tintColor: UIColor, errorImage: UIImage) -> RemoteImageServiceOverlayView {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.color = tintColor
        let errorView = UIImageView(image: errorImage)
        return RemoteImageServiceOverlayView(loadingView: activityIndicator,
                                             errorView: errorView)
    }
    
    public func serviceDidEndRequest(_ service: AnyService) {
        DispatchQueue.main.async {
            self.loadingView.removeFromSuperview()
            if
                let errorView = self.errorView,
                service.lastError != nil,
                service.lastError != .requestCancelled,
                service.lastError != .redundantRequest
            {
                self.addAndFillSubview(errorView)
            } else {
                self.errorView?.removeFromSuperview()
            }
        }
    }
    
    public func serviceWillStartRequest(_ service: AnyService) {
        DispatchQueue.main.async {
            self.addAndFillSubview(self.loadingView)
            self.errorView?.removeFromSuperview()
        }
    }
    
    private func addAndFillSubview(_ subview: UIView) {
        guard
            let superview = superview
            else { return }
        superview.addSubview(subview)
        superview.fillSubview(subview)
    }
    
}
