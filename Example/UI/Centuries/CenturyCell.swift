//
//  CenturyCell.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

class CenturyCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var objectNumberLabel: UILabel!
    @IBOutlet private weak var lastUpdateLabel: UILabel!
    
    func configure(century: Century) {
        nameLabel.text = century.name
        objectNumberLabel.text = String(century.objectCount ?? 0)
        lastUpdateLabel.text = century.formattedDate
    }
    
}
