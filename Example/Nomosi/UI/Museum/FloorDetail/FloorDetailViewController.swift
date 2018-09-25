//
//  FloorDetailViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class FloorDetailViewController: PaginatedViewController {
    
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
        var service: GalleriesGallery?
        if galleries.count == 0 || nextPageLink != nil {
            service = GalleriesGallery(nextPageLink: nextPageLink, id: floorID)
        } 
        service?
            .load()?
            .addingObserver(activeServiceOverlay)
            .onSuccess { [weak self] response in
                self?.nextPageLink = response.paginatedServiceInfo.next
                self?.insertObjects(response.galleries)
            }
            .onCompletion { [weak self] _, _ in
                self?.currentService = nil
            }
        currentService = service
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard
            let galleryViewController = segue.destination as? GalleryViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
            else { return }
        let selectedGallery = Array(galleries)[indexPath.row]
        galleryViewController.galleryName = selectedGallery.name
        galleryViewController.galleryID = selectedGallery.id
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

extension FloorDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return galleries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "GalleryCell", for: indexPath) as? GalleryCell
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
