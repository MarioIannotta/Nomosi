//
//  CenturyDetailViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class CenturyDetailViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet private weak var tableView: UITableView!
  
  // MARK: - Model
  
  var century: Century?
  var centuryID: Int = -1
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = century?.name
    centuryID = century?.id ?? -1
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    century = nil
    let centuryService = CenturyService(id: centuryID)
    if #available(iOS 15.0, *) {
      Task {
        century = try? await centuryService.load()
        reloadContent()
      }
    } else {
      centuryService
        .load()
        .onSuccess { [weak self] century in
          self?.century = century
          self?.reloadContent()
        }
    }
  }
  
  private func reloadContent() {
    tableView.reloadData()
  }
}

extension CenturyDetailViewController: UITableViewDataSource, UITableViewDelegate {
  
  // MARK: - UITableViewDataSource
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return century?.detail?.groups?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard
      let cell = tableView.dequeueReusableCell(withIdentifier: GroupCell.identifier,
                                               for: indexPath) as? GroupCell,
      let group = century?.detail?.groups?[indexPath.row]
    else {
      return UITableViewCell()
    }
    cell.configure(group: group)
    return cell
  }
  
  // MARK: - UITableViewDelegate
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}
