//
//  FloorCell.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

class FloorCell: UITableViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    func configure(floor: Floor) {
        titleLabel.text = floor.name
    }
    
}
