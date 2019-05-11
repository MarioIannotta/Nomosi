//
//  FloorsViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class DownloadService: Nomosi.DownloadService {
    
    override init() {
        super.init()
        url = URL(string: "https://cbcdn2.gp-static.com/uploads/product_manual/file/202/HERO3_Plus_Black_UM_ENG_REVD.pdf")
    }
    
}


class FloorsViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var serviceOverlayView: ServiceOverlayView!
    
    // MARK: - Model
    
    private var floors = [Floor]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        serviceOverlayView = ServiceOverlayView(cover: view, keepOnError: true)
        loadData()
        download()
    }
    
    private func loadData() {
        let service = FloorsService()
        service
            .addingObserver(serviceOverlayView)
            .load()?
            .onSuccess { [weak self] floors in
                self?.floors = floors
                self?.tableView.reloadData()
            }
    }
    
    private func download() {
        let service = DownloadService()
        service
            .load()?
            .onProgress { progress in
                print(progress.fractionCompleted)
            }
            .onSuccess { url in
                print(url)
                
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard
            let floorDetailViewController = segue.destination as? GalleriesViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell)
            else { return }
        floorDetailViewController.floorID = indexPath.row
        floorDetailViewController.floorName = floors[indexPath.row].name
    }
    
}

extension FloorsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return floors.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: FloorTableViewCell.identifier,
                                                     for: indexPath) as? FloorTableViewCell
            else {
                return UITableViewCell()
            }
        cell.configure(floor: floors[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
