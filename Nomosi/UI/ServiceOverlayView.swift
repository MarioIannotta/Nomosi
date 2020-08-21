//
//  ServiceOverlayView.swift
//  Nomosi
//
//  Created by Mario on 13/05/2018.
//  Copyright © 2018 Mario. All rights reserved.
//

import UIKit

open class ServiceOverlayView: UIView {
    
    private var viewToCover: UIView?
    private var viewToConverObservation: NSKeyValueObservation?
    private var contentStackView = UIStackView(frame: .zero)
    private var buttonsStackView = UIStackView(frame: .zero)
    private var activityIndicator = UIActivityIndicatorView(style: .gray)
    private var errorLabel = UILabel(frame: .zero)
    private var tryAgainButton = UIButton(type: .system)
    private var cancelButton = UIButton(type: .system)
    
    private var keepOnError: Bool = false
    private var onCancel: (() -> Void)?
    private var hasError: Bool = false
    private var loadingServices = [AnyService]()
    private var servicesWithError = [AnyService]()
    
    private var hasLoadingServices: Bool { loadingServices.count > 0 }
    private var hasServicesWithError: Bool { servicesWithError.count > 0 }
    
    public init(cover viewToCover: UIView,
                keepOnError: Bool = true,
                onCancel: (() -> Void)? = nil) {
        super.init(frame: .zero)
        self.viewToCover = viewToCover
        self.keepOnError = keepOnError
        self.onCancel = onCancel
        setup()
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
        viewToConverObservation?.invalidate()
        viewToConverObservation = nil
        viewToCover = nil
    }
    
    private func setup() {
        setupView()
        setupActivityIndicator()
        setupErrorLabel()
        setupTryAgainButton()
        setupCancelButton()
        setupContentStackView()
        setupButtonsStackView()
    }
    
    private func setupView() {
        backgroundColor = UIColor(white: 1, alpha: 1)
        viewToConverObservation = viewToCover?.observe(\.frame) { [weak self] _, _ in
            self?.refreshSize()
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = false
    }
    
    private func setupErrorLabel() {
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        setError(nil)
    }
    
    private func setupTryAgainButton() {
        tryAgainButton.setTitle("Try again", for: .normal)
        tryAgainButton.addTarget(self, action: #selector(tryAgainButtonDidTap), for: .touchUpInside)
        styleButton(tryAgainButton, color: tryAgainButton.tintColor)
    }
    
    private func setupCancelButton() {
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        styleButton(cancelButton, color: .red)
    }
    
    private func styleButton(_ button: UIButton, color: UIColor) {
        button.tintColor = color
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = button.tintColor.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        button.sizeToFit()
        button.isHidden = true
    }
    
    private func setupContentStackView() {
        addSubview(contentStackView)
        [activityIndicator, errorLabel, buttonsStackView].forEach {
            contentStackView.addArrangedSubview($0)
        }
        contentStackView.alignment = .center
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 20
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: contentStackView.leftAnchor, constant: -20),
            rightAnchor.constraint(equalTo: contentStackView.rightAnchor, constant: 20),
            centerYAnchor.constraint(equalTo: contentStackView.centerYAnchor)])
    }
    
    private func setupButtonsStackView() {
        [tryAgainButton, cancelButton].forEach {
            buttonsStackView.addArrangedSubview($0)
        }
        buttonsStackView.spacing = 10
    }
    
    fileprivate func setError(_ serviceError: ServiceError?) {
        self.hasError = serviceError != nil
        DispatchQueue.main.async { [weak self] in
            self?.errorLabel.text = serviceError?.reason ?? ""
            self?.tryAgainButton.isHidden = serviceError == nil
            self?.cancelButton.isHidden = serviceError == nil
        }
    }
    
    private func refreshSize() {
        frame = viewToCover?.bounds ?? .zero
    }
    
    @objc private func tryAgainButtonDidTap() {
        servicesWithError.forEach { $0.load(completion: nil) }
    }
    
    @objc private func cancelButtonDidTap() {
        removeFromSuperview()
        onCancel?()
    }
    
    private func addOverlayIfNeeded() {
        guard
            self.hasLoadingServices || self.superview != nil
            else { return }
        setError(nil)
        servicesWithError = []
        DispatchQueue.main.async { [weak self] in
            guard
                let self = self
                else { return }
            self.viewToCover?.addSubview(self)
            self.refreshSize()
        }
    }
    
    private func removeOverlayViewIfNeeded() {
        DispatchQueue.main.async {
            if !self.hasLoadingServices && (!self.hasServicesWithError || !self.keepOnError) {
                self.removeFromSuperview()
            }
        }
    }
    
    private func setActivityIndicator(hidden isHidden: Bool) {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = isHidden
        }
    }
    
    private func hideActivityIndicatorIfNeeded() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.isHidden = self?.loadingServices.count == 0
        }
    }
    
    private func serviceDidStartLoad(_ service: AnyService) {
        loadingServices.appendIfNotExists(service)
        hideActivityIndicatorIfNeeded()
        addOverlayIfNeeded()
    }
    
    private func serviceDidEndLoad(_ service: AnyService) {
        loadingServices.remove(service)
        /*
         if there's an error, and that error is not the redundant request
         error (we want this error to be silent), let's display the error message
         */
        if let lastError = service.lastError, lastError != ServiceError.redundantRequest {
            setError(service.lastError)
            servicesWithError.appendIfNotExists(service)
        } else {
            servicesWithError.remove(service)
        }
        hideActivityIndicatorIfNeeded()
        removeOverlayViewIfNeeded()
    }
}

extension ServiceOverlayView: ServiceObserver {
    
    public func serviceWillStartRequest(_ service: AnyService) {
        serviceDidStartLoad(service)
    }
    
    public func serviceDidEndRequest(_ service: AnyService) {
        serviceDidEndLoad(service)
    }
}
