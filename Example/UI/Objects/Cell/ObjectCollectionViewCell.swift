//
//  ObjectCollectionViewCell.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

struct ObjectCollectionViewCellViewModel {
    let object: Object
    let onDownloadButtonTapped: ((_ object: Object, _ serviceObserver: ServiceObserver) -> Void)
    let isImageDownloaded: Bool
}

class ObjectCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var centuryLabel: UILabel!
    @IBOutlet private weak var centuryContainerView: UIView!
    @IBOutlet private weak var classificationLabel: UILabel!
    @IBOutlet private weak var classificationContainerView: UIView!
    @IBOutlet private weak var previewImageView: UIImageView!
    @IBOutlet private weak var downloadButton: ServiceObserverButton!
    
    private var viewModel: ObjectCollectionViewCellViewModel?
    private let placeholder: RemoteImageServiceOverlayView = .activityIndicator(tintColor: .black,
                                                                                errorImage: #imageLiteral(resourceName: "image_placeholder"))
    private var loadImageService: HarvardRemoteImageService?
    
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
        downloadButton.layer.cornerRadius = downloadButton.bounds.height/2
        let downloadButtonCompactiSize = CGSize(width: downloadButton.bounds.height, height: downloadButton.bounds.height)
        downloadButton.setLoadingActions(
            .disableUserInteraction,
            .showLoader(animated: true),
            .hideContent(animated: false),
            .resize(newSize: downloadButtonCompactiSize, animated: true),
            .onCompletion({ [weak self] _, hasError in
                guard
                    !hasError
                    else { return }
                self?.setupDownloadButton(isImageDownloaded: true)
            })
        )
    }
    
    func configure(viewModel: ObjectCollectionViewCellViewModel) {
        self.viewModel = viewModel
        titleLabel.text = viewModel.object.title
        centuryLabel.text = viewModel.object.century
        classificationLabel.text = viewModel.object.classification
        centuryContainerView.isHidden = (centuryLabel.text?.count ?? 0) == 0
        classificationContainerView.isHidden = (classificationLabel.text?.count ?? 0) == 0
        downloadButton.isHidden = viewModel.object.primaryimageurl?.isEmpty ?? true
        setupDownloadButton(isImageDownloaded: viewModel.isImageDownloaded)
        let imageLink = viewModel.object.primaryimageurl ?? ""
        let loadImageService = HarvardRemoteImageService(link: "\(imageLink)?height=200&width=200")
        self.loadImageService = previewImageView.loadImage(service: loadImageService,
                                                           overlayView: placeholder)
    }
    
    private func setupDownloadButton(isImageDownloaded: Bool) {
        downloadButton.isUserInteractionEnabled = !isImageDownloaded
        downloadButton.setTitle(isImageDownloaded ? "✓ Saved " : "Download", for: .normal)
    }
    
    override func prepareForReuse() {
        loadImageService?.cancelRequest()
    }
    
    @IBAction private func downloadButtonTapped() {
        guard
            let viewModel = viewModel
            else { return }
        viewModel.onDownloadButtonTapped(viewModel.object, downloadButton)
    }
}
