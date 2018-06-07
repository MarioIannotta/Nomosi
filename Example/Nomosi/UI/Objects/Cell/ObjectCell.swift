//
//  ObjectCell.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit

class ObjectCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var centuryLabel: UILabel!
    @IBOutlet private weak var centuryContainerView: UIView!
    @IBOutlet private weak var classificationLabel: UILabel!
    @IBOutlet private weak var classificationContainerView: UIView!
    @IBOutlet private weak var previewImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 8
        previewImageView.layer.cornerRadius = 8
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.05
        containerView.layer.shadowOffset = .zero
        centuryContainerView.layer.cornerRadius = 8
        classificationContainerView.layer.cornerRadius = 8
    }
    
    func configure(object: Object) {
        titleLabel.text = object.title
        centuryLabel.text = object.century
        classificationLabel.text = object.classification
        let imageLink = object.images?.first(where: { $0.baseimageurl != nil })?.baseimageurl ?? ""
        previewImageView.loadImage(link: "\(imageLink)?height=200&width=200",
                                   cachePolicy: .onDisk(timeout: 60*5)) // disk cache for 5 minutes
    }
    
    override func prepareForReuse() {
        previewImageView.image = nil
    }
    
}
