//
//  ServiceOverlayView.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import UIKit

extension ServiceOverlayView: ServiceObserver {
    
    public func serviceDidStartRequest(_ service: AnyService) {
        addService()
    }
    
    public func serviceDidEndRequest(_ service: AnyService, response: ServiceResponse?, error: Error?) {
        removeService()
    }
    
}

open class ServiceOverlayView: UIView {
    
    private var loadingServicesCount = 0 
    
    private weak var viewToCover: UIView?
    private var activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    private var viewToConverObservation: NSKeyValueObservation?
    
    public init(cover viewToCover: UIView) {
        super.init(frame: .zero)
        setup()
        cover(view: viewToCover)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    deinit {
        viewToConverObservation = nil
    }
    
    public func cover(view: UIView) {
        viewToCover = view
        viewToConverObservation = view.observe(\.bounds) { [weak self] _, _ in
            self?.refreshSize()
        }
    }
    
    private func setup() {
        backgroundColor = UIColor(white: 1, alpha: 1)
        activityIndicator.startAnimating()
        addSubview(activityIndicator)
    }
    
    private func refreshSize() {
        frame = viewToCover?.bounds ?? .zero
        activityIndicator.center = center
    }
    
    private func addOverlayIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            guard self.loadingServicesCount > 0 || self.superview != nil else { return }
            self.viewToCover?.addSubview(self)
            self.refreshSize()
        }
    }
    
    private func removeOverlayViewIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard self?.loadingServicesCount == 0 else { return }
            self?.removeFromSuperview()
        }
    }
    
    internal func addService() {
        loadingServicesCount += 1
        addOverlayIfNeeded()
    }
    
    internal func removeService() {
        loadingServicesCount -= 1
        removeOverlayViewIfNeeded()
    }
    
}
