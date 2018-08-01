//
//  ObjectsViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class ObjectsViewController: PaginatedViewController {
    
    // MARK: - Config
    
    struct Config {
        var numberOfItemsForRow: CGFloat = 2
        var horizontalPadding: CGFloat = 10
        var topPadding: CGFloat = 10
        var bottomPadding: CGFloat = 120
        var cellHeight: CGFloat = 280
    }
    
    private var config = Config()
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var footerView: UIView!
    
    // MARK: - Model
    
    private var objects: Set<Object> = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPaginatedController(scrollView: collectionView, footerView: footerView)
    }

    override func resetDataSource() {
        super.resetDataSource()
        objects = []
        collectionView.reloadData()
    }
    
    private func insertObjects(_ objects: [Object]) {
        var indexPathsToAdd = [IndexPath]()
        objects.enumerated().forEach { index, object in
            if !self.objects.contains(object) {
                indexPathsToAdd.append(IndexPath(row: index, section: 0))
                self.objects.insert(object)
            }
        }
        collectionView.reloadData()
    }
    
    override func loadNextPage() {
        var service: ObjectsService?
        if objects.count == 0 {
            service = ObjectsService()
        } else if nextPageLink != nil {
            service = ObjectsService(nextPageLink: nextPageLink)
        } else {
            // if objects.count > 0 and nextPageLink == nil it's the end of the list
        }
        service?
            .load()?
            .addingObserver(activeServiceOverlay)
            .onSuccess { [weak self] response in
                self?.nextPageLink = response.paginatedServiceInfo.next
                self?.insertObjects(response.objects)
            }
            .onCompletion { [weak self] _, _ in
                self?.currentService = nil
            }
        currentService = service
    }
    
    // MARK: - IBActions
    
    @IBAction private func cancelRequest() {
        super.cancelOnGoingRequest()
    }
    
    @IBAction private func refreshButtonTapped() {
        resetDataSource()
        loadNextPage()
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
        cell.configure(object: Array(objects)[indexPath.item])
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
