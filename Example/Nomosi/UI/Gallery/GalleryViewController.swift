//
//  GalleryViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 25/09/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

class GalleryViewController: PaginatedViewController {

    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var footerView: UIView!
    
    // MARK: - Injectable properties
    
    var galleryID: Int = -1
    var galleryName: String = ""
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = galleryName
        setupPaginatedController(scrollView: tableView, footerView: footerView)
    }
    
}
