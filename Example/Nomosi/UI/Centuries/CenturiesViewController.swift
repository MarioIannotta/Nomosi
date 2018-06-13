//
//  CenturiesViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 13/05/2018.
//  Copyright (c) 2018 MarioIannotta. All rights reserved.
//

import UIKit
import Nomosi

class CenturiesViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!

    // MARK: - Model
    
    private var centuries: [Century] = []
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        CenturiesService()
            .load(usingOverlay: ServiceOverlayView(cover: view))?
            .onSuccess { [weak self] response in
                self?.centuries = response
                                    .centuries
                                    .sorted(by: { ($0.temporalOrder ?? 0) < ($1.temporalOrder ?? 0) })
                self?.tableView.reloadData()
            }
            .onFailure { error in
                // TODO: handle error
            }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard
            let centuryDetailViewController = segue.destination as? CenturyDetailViewController,
            let selectedCell = sender as? UITableViewCell,
            let selectedIndexPath = tableView.indexPath(for: selectedCell)
            else { return }
        centuryDetailViewController.century = centuries[selectedIndexPath.row]
    }

}

extension CenturiesViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return centuries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "CenturyCell", for: indexPath) as? CenturyCell
            else { return UITableViewCell() }
        cell.configure(century: centuries[indexPath.row])
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
