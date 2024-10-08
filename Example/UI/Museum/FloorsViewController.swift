//
//  FloorsViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class FloorsViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet private weak var tableView: UITableView!
  
  // MARK: - Model
  
  private var floors = [Floor]()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadData()
  }
  
  private func loadData() {
    let service = FloorsService()
    if #available(iOS 13.0, *) {
      Task {
        for await (floors, source) in service.anySuccess {
          print("got \(floors.count) floors from \(source)")
          self.floors = floors
          self.tableView.reloadData()
        }
      }
    } else {
      service
        .onSuccess { [weak self] floors in
          self?.floors = floors
          self?.tableView.reloadData()
        }
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
