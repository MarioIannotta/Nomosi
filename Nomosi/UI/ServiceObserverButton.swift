//
//  ServiceObserverButton.swift
//  Nomosi_Example
//
//  Created by Mario on 07/10/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

open class ServiceObserverButton: UIButton {
    
    public typealias CompletionClosure = (_ button: UIButton, _ hasError: Bool) -> Void
    public typealias LoadingActionClosure = (_ button: UIButton) -> Void
    
    public enum LoadingAction: Equatable {
        
        case showLoader(animated: Bool)
        case disableUserInteraction
        case hideContent(animated: Bool)
        case resize(newSize: CGSize, animated: Bool)
        case onCompletion(CompletionClosure)
        case custom(id: Int, perform: LoadingActionClosure, unwind: LoadingActionClosure)
        
        private var id: Int {
            switch self {
            case .showLoader:
                return 1
            case .disableUserInteraction:
                return 2
            case .hideContent:
                return 3
            case .resize:
                return 4
            case .onCompletion:
                return 5
            case .custom(let id, _, _):
                return id
            }
        }
        
        // MARK: - Equatable
        
        public static func == (lhs: ServiceObserverButton.LoadingAction,
                               rhs: ServiceObserverButton.LoadingAction) -> Bool {
            return lhs.id == rhs.id
        }
        
    }
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.startAnimating()
        activityIndicatorView.color = tintColor
        return activityIndicatorView
    }()
    
    private var oldConstraints = [NSLayoutConstraint: CGFloat]()
    private var newSizeConstraints = [NSLayoutConstraint]()
    
    private var loadingActions: [LoadingAction] = [.showLoader(animated: true),
                                                   .disableUserInteraction]
    
    private var loadingServices = [AnyService]()
    private var failedServices = [AnyService]()
    
    public func setLoadingActions(_ loadingActions: LoadingAction...) {
        self.loadingActions = loadingActions
    }
    
    private func performLoadingAction(_ loadingAction: LoadingAction) {
        switch loadingAction {
        case .showLoader(let animated):
            editLoader(add: true, animated: animated)
        case .disableUserInteraction:
            isUserInteractionEnabled = false
        case .hideContent(let animated):
            setContent(alpha: 0, animated: animated)
        case .resize(let newSize, let animated):
            setNewSize(newSize, animated: animated)
        case .custom(_, let performClosure, _):
            performClosure(self)
        default:
            break
        }
    }
    
    private func unwindLoadingAction(_ loadingAction: LoadingAction) {
        switch loadingAction {
        case .showLoader(let animated):
            editLoader(add: false, animated: animated)
        case .disableUserInteraction:
            isUserInteractionEnabled = true
        case .hideContent(let animated):
            setContent(alpha: 1, animated: animated)
        case .resize(_, let animated):
            setNewSize(nil, animated: animated)
        case .custom(_, _, let unwindClosure):
            unwindClosure(self)
        default:
            break
        }
    }
    
    private func editLoader(add: Bool, animated: Bool) {
        activityIndicatorView.alpha = add ? 0 : 1
        if add {
            addAndSetupLoader()
        }
        UIView.animate(
            withDuration: animated ? 0.3 : 0,
            animations: { [weak self] in
                self?.activityIndicatorView.alpha = add ? 1 : 0
            },
            completion: { [weak self] _ in
                if !add {
                    self?.activityIndicatorView.removeFromSuperview()
                }
            })
    }
    
    private func addAndSetupLoader() {
        addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)]
        if loadingActions.contains(.hideContent(animated: true)) {
            constraints += [activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)]
        } else if let contentView = titleLabel ?? imageView {
            constraints += [contentView.leadingAnchor.constraint(equalTo: activityIndicatorView.trailingAnchor,
                                                                 constant: 10)]
        }
        NSLayoutConstraint.activate(constraints)
        layoutIfNeeded()
    }
    
    private func setNewSize(_ newSize: CGSize?, animated: Bool) {
        defer {
            UIView.animate(withDuration: animated ? 0.3 : 0) { [weak self] in
                self?.superview?.layoutIfNeeded()
            }
        }
        if newSize == nil {
            NSLayoutConstraint.deactivate(newSizeConstraints)
            oldConstraints.forEach {
                $0.key.constant = $0.value
            }
        } else {
            constraints.forEach {
                oldConstraints[$0] = $0.constant
            }
        }
        guard
            let newSize = newSize
            else { return }
        
        newSizeConstraints = [
            widthAnchor.constraint(equalToConstant: newSize.width),
            heightAnchor.constraint(equalToConstant: newSize.height)
        ]
        
        NSLayoutConstraint.activate(newSizeConstraints)
    }
    
    private func setContent(alpha: CGFloat, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0) { [weak self] in
            self?.titleLabel?.alpha = alpha
            self?.imageView?.alpha = alpha
        }
    }
    
    private func performLoadingActionsIfNeeded() {
        guard
            loadingServices.count == 1
            else { return }
        DispatchQueue.main.async { [weak self] in
            self?.loadingActions.forEach { self?.performLoadingAction($0) }
        }
    }
    
    private func performUnwindActionsIfNeeded() {
        guard
            loadingServices.count == 0
            else { return }
        DispatchQueue.main.async { [weak self] in
            guard
                let self = self
                else { return }
            self.loadingActions.forEach {
                self.unwindLoadingAction($0)
                if case .onCompletion(let closure) = $0 {
                    closure(self, self.failedServices.count > 0 ? true : false)
                }
            }
        }
    }
    
}

extension ServiceObserverButton: ServiceObserver {
    
    public func serviceWillStartRequest(_ service: AnyService) {
        loadingServices.appendIfNotExists(service)
        performLoadingActionsIfNeeded()
    }
    
    public func serviceDidEndRequest(_ service: AnyService) {
        if service.lastError != nil {
            failedServices.appendIfNotExists(service)
        } else {
            failedServices.remove(service)
        }
        loadingServices.remove(service)
        performUnwindActionsIfNeeded()
    }
    
}
