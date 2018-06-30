//
//  ObjectsViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class ObjectsViewController: UIViewController {
    
    // MARK: - Config
    
    struct Config {
        var numberOfItemsForRow: CGFloat = 2
        var horizontalPadding: CGFloat = 10
        var topPadding: CGFloat = 10
        var bottomPadding: CGFloat = 120
        var cellHeight: CGFloat = 280
    }
    
    private var config = Config()
    private var shouldLoadNextPage: Bool {
        return collectionView.contentSize.height - collectionView.contentOffset.y - collectionView.frame.height < 100 || objects.count == 0
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var footerView: UIView! {
        didSet {
            footerServiceOverlayView = ServiceOverlayView(cover: footerView)
            footerServiceOverlayView?.backgroundColor = .clear
        }
    }
    
    private var footerServiceOverlayView: ServiceOverlayView?
    
    // MARK: - Model
    
    private var objects: [Object] = []
    private var lastLoadedPageLink: String? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNextPageIfNeeded()
    }
    
    func resetDataSource() {
        lastLoadedPageLink = nil
        objects = []
        collectionView.reloadData()
    }
    
    private func insertObjects(_ objects: [Object]) {
        var indexPathsToAdd = [IndexPath]()
        for index in self.objects.count..<self.objects.count+objects.count {
            indexPathsToAdd.append(IndexPath(row: index, section: 0))
        }
        self.objects += objects
        collectionView.insertItems(at: indexPathsToAdd)
    }
    
    private func loadNextPageIfNeeded() {
        guard shouldLoadNextPage else { return }
        let overlay = lastLoadedPageLink == nil ? ServiceOverlayView(cover: view) : footerServiceOverlayView
        _ = ObjectsService(nextPage: lastLoadedPageLink)?
            .onSuccess { [weak self] response in
                self?.lastLoadedPageLink = response.paginatedServiceInfo.next
                self?.insertObjects(response.objects)
            }
            .load(usingOverlay: overlay)
    }
    
}

extension ObjectsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        loadNextPageIfNeeded()
    }
    
}

extension ObjectsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ObjectCell", for: indexPath) as? ObjectCell
            else { return UICollectionViewCell() }
        cell.configure(object: objects[indexPath.item])
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - (config.numberOfItemsForRow + 1) * config.horizontalPadding)/config.numberOfItemsForRow
        return CGSize(width: width, height: config.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: config.topPadding,
                            left: config.horizontalPadding,
                            bottom: config.bottomPadding,
                            right: config.horizontalPadding)
    }
    
}
