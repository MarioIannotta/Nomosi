//
//  GalleryTableViewCell.swift
//  Nomosi_Example
//
//  Created by Mario on 01/08/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

class GalleryTableViewCell: UITableViewCell {
  
  @IBOutlet private weak var nameLabel: UILabel!
  @IBOutlet private weak var themeLabel: UILabel!
  @IBOutlet private weak var descriptionLabel: UILabel!
  @IBOutlet private weak var descriptionContainerView: UIView! {
    didSet {
      descriptionContainerView.layer.cornerRadius = 5
    }
  }
  
  private var onExpandButtonTapped: (() -> Void)?
  
  func configure(gallery: Gallery, isExpanded: Bool, onExpandButtonTapped: (@escaping () -> Void)) {
    self.onExpandButtonTapped = onExpandButtonTapped
    nameLabel.text = gallery.name
    themeLabel.text = gallery.theme
    themeLabel.isHidden = gallery.theme?.isEmpty == true
    let descriptionText = isExpanded ? gallery.labelText : gallery.summaryLabelText
    if let descriptionText = descriptionText {
      descriptionContainerView.isHidden = false
      descriptionLabel.text = descriptionText
    } else {
      descriptionContainerView.isHidden = true
    }
  }
  
  @IBAction private func expandButtonTapped() {
    onExpandButtonTapped?()
  }   
}
