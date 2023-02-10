//
//  PaginatedViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class PaginatedViewController: UIViewController {
    
    public var nextPageLink: String? = nil 
    public var currentService: AnyService?
    
    private var paginatedScrollView: UIScrollView?
    private let heightThreshold: CGFloat = 200
    
    private func shouldLoadNextPage(contentOffset: CGPoint) -> Bool {
        guard
            let scrollView = paginatedScrollView
            else {
                return false
            }
        return scrollView.contentSize.height - contentOffset.y - scrollView.frame.height < heightThreshold
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNextPageIfNeeded(contentOffset: paginatedScrollView?.contentOffset ?? .zero)
    }
    
    public func setupPaginatedController(scrollView: UIScrollView, footerView: UIView) {
        paginatedScrollView = scrollView
    }
    
    public func resetDataSource() {
        nextPageLink = nil
    }
    
    public func cancelOnGoingRequest() {
        currentService?.cancelRequest()
    }
    
    public func loadNextPage() {
        // To override
    }
    
    private func loadNextPageIfNeeded(contentOffset: CGPoint) {
        guard
            shouldLoadNextPage(contentOffset: contentOffset)
            else { return }
        loadNextPage()
    }
}

extension PaginatedViewController: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        loadNextPageIfNeeded(contentOffset: targetContentOffset.pointee)
    }   
}
