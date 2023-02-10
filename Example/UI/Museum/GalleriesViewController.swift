//
//  GalleriesViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class GalleriesViewController: PaginatedViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var footerView: UIView!
    
    private var selectedIndexPath: IndexPath? = nil
    
    // MARK: - Injectable properties
    
    var floorID: Int = -1
    var floorName: String = ""
    
    // MARK: - Model
    
    private var galleries = Set<Gallery>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = floorName
        setupPaginatedController(scrollView: tableView, footerView: footerView)
    }
    
    override func loadNextPage() {
        var service: GalleriesService?
        if galleries.count == 0 || nextPageLink != nil {
            service = GalleriesService(nextPageLink: nextPageLink, id: floorID)
        }
        guard let service = service
        else {
            currentService = nil
            return
        }

        if #available(iOS 15.0, *) {
            Task {
                if let response = try? await service.load() {
                    nextPageLink = response.paginatedServiceInfo.next
                    insertObjects(response.galleries)
                }
            }
            currentService = nil
        } else {
            service
                .load()
                .onSuccess { [weak self] response in
                    self?.nextPageLink = response.paginatedServiceInfo.next
                    self?.insertObjects(response.galleries)
                }
                .onCompletion { [weak self] _ in
                    self?.currentService = nil
                }
        }
        currentService = service
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard
            let objectsViewController = segue.destination as? ObjectsViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
            else { return }
        let selectedGallery = Array(galleries)[indexPath.row]
        objectsViewController.galleryName = selectedGallery.name
        objectsViewController.galleryID = selectedGallery.id
    }
    
    private func insertObjects(_ galleries: [Gallery]) {
        var indexPathsToAdd = [IndexPath]()
        galleries.enumerated().forEach { index, gallery in
            if !self.galleries.contains(gallery) {
                indexPathsToAdd.append(IndexPath(row: index, section: 0))
                self.galleries.insert(gallery)
            }
        }
        tableView.reloadData()
    }
    
    private func select(rowAtIndexPath: IndexPath) {
        var indexPathsToReload = [rowAtIndexPath]
        if let oldSelectedIndexPath = selectedIndexPath {
            indexPathsToReload.append(oldSelectedIndexPath)
            if oldSelectedIndexPath == rowAtIndexPath {
                selectedIndexPath = nil
            } else {
                selectedIndexPath = rowAtIndexPath
            }
        } else {
            selectedIndexPath = rowAtIndexPath
        }
        tableView.reloadRows(at: indexPathsToReload, with: .fade)
    }
}

extension GalleriesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        galleries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: GalleryTableViewCell.identifier,
                                                     for: indexPath) as? GalleryTableViewCell
            else {
                return UITableViewCell()
            }
        cell.configure(gallery: Array(galleries)[indexPath.row],
                       isExpanded: selectedIndexPath == indexPath,
                       onExpandButtonTapped: { [weak self] in
                            self?.select(rowAtIndexPath: indexPath)
                       })
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
