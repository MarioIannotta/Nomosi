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
        var verticalPadding: CGFloat = 10
        var cellHeight: CGFloat = 280
    }
    
    private var config = Config()
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - Model
    
    private var objects: [Object] = []
    private var isLoadingInProgress = false
    private var lastLoadedPageLink: String? = nil
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadNextPage()
    }
    
    private func insertObjects(_ objects: [Object]) {
        var indexPathsToAdd = [IndexPath]()
        for index in self.objects.count..<self.objects.count+objects.count {
            indexPathsToAdd.append(IndexPath(row: index, section: 0))
        }
        self.objects += objects
        collectionView.insertItems(at: indexPathsToAdd)
    }
    
    private func loadNextPage() {
        guard !isLoadingInProgress else { return }
        let overlay = lastLoadedPageLink == nil ? ServiceOverlayView(cover: view) : nil
        isLoadingInProgress = true
        ObjectsService(nextPage: lastLoadedPageLink)?
            .onSuccess { [weak self] response in
                self?.lastLoadedPageLink = response.paginatedServiceInfo.next
                self?.insertObjects(response.objects)
            }
            .onCompletion { [weak self] _, _ in
                self?.isLoadingInProgress = false
            }
            .load(usingOverlay: overlay)
    }
    
}

extension ObjectsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let threshold = scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.height
        if threshold < 100 {
            loadNextPage()
        }
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
        return UIEdgeInsets(top: config.verticalPadding,
                            left: config.horizontalPadding,
                            bottom: config.verticalPadding,
                            right: config.horizontalPadding)
    }
    
}
