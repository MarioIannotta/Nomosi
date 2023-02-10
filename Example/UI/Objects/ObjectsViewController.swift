//
//  ObjectsViewController.swift
//  Nomosi_Example
//
//  Created by Mario on 07/06/2018.
//  Copyright © 2018 Mario Iannotta. All rights reserved.
//

import UIKit
import Nomosi

class ObjectsViewController: PaginatedViewController<ObjectsService, ObjectsServiceResponse> {
  
  // MARK: - Config
  
  struct Config {
    var numberOfItemsForRow: CGFloat = 2
    var horizontalPadding: CGFloat = 10
    var topPadding: CGFloat = 10
    var bottomPadding: CGFloat = 120
    var cellHeight: CGFloat = 280
  }
  
  private var config = Config()
  private var downloadedImagesObjectID: [Int?] = []
  
  // MARK: - Injectable properties
  
  var galleryName: String?
  var galleryID: Int?
  
  // MARK: - IBOutlets
  
  @IBOutlet private weak var collectionView: UICollectionView!
  @IBOutlet private weak var footerView: UIView!
  
  // MARK: - Model
  
  private var objects = [Object]()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    title = galleryName ?? "Recent Objects"
    setupPaginatedController(scrollView: collectionView, footerView: footerView)
  }
  
  override func resetDataSource() {
    super.resetDataSource()
    objects = []
    collectionView.reloadData()
  }
  
  private func insertObjects(_ objects: [Object]) {
    var indexPathsToAdd = [IndexPath]()
    objects.enumerated().forEach { index, object in
      if !self.objects.contains(object) {
        indexPathsToAdd.append(IndexPath(row: index, section: 0))
        self.objects.append(object)
      }
    }
    collectionView.reloadData()
  }
  
  override func loadNextPage() {
    var service: ObjectsService?
    if objects.count == 0 {
      service = ObjectsService(galleryID: galleryID)
    } else if nextPageLink != nil {
      service = ObjectsService(galleryID: galleryID, nextPageLink: nextPageLink)
    } else {
      // if objects.count > 0 and nextPageLink == nil it's the end of the list
    }
    guard let service = service
    else {
      currentService = nil
      return
    }
    if #available(iOS 15.0, *) {
      Task {
        if let response = try? await service.load() {
          nextPageLink = response.paginatedServiceInfo.next
          insertObjects(response.objects)
        }
        currentService = nil
      }
    } else {
      service
        .load()
        .onSuccess { [weak self] response in
          self?.nextPageLink = response.paginatedServiceInfo.next
          self?.insertObjects(response.objects)
        }
        .onCompletion { [weak self] _ in
          self?.currentService = nil
        }
    }
    currentService = service
  }
  
  private func downloadObjectPrimaryPhoto(object: Object) {
    guard
      let imageLink = object.primaryimageurl
    else { return }
    let service = HarvardRemoteImageService(link: imageLink)
    if #available(iOS 15.0, *) {
      Task {
        do {
          let image = try await service.load()
          handleDownloadObjectPrimaryPhotoServiceResult(.success(image), object: object)
        } catch let error as ServiceError {
          handleDownloadObjectPrimaryPhotoServiceResult(.failure(error), object: object)
        }
      }
    } else {
      service
        .load()
        .onCompletion { [weak self] result in
          self?.handleDownloadObjectPrimaryPhotoServiceResult(result, object: object)
        }
    }
  }
  
  private func handleDownloadObjectPrimaryPhotoServiceResult(_ result: Result<UIImage, ServiceError>, object: Object) {
    switch result {
    case .success(let image):
      downloadedImagesObjectID.append(object.objectid)
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    case .failure(let error):
      let alertController = UIAlertController(title: "Error", message: error.description, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
      present(alertController, animated: true, completion: nil)
    }
  }
  
  // MARK: - IBActions
  
  @IBAction private func cancelRequest() {
    super.cancelOnGoingRequest()
  }
  
  @IBAction private func refreshButtonTapped() {
    resetDataSource()
    loadNextPage()
  }
}

extension ObjectsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  // MARK: - UICollectionViewDataSource
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return objects.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ObjectCollectionViewCell.identifier,
                                                    for: indexPath) as? ObjectCollectionViewCell
    else {
      return UICollectionViewCell()
    }
    let viewModel = ObjectCollectionViewCellViewModel(
      object: objects[indexPath.item],
      onDownloadButtonTapped: { [weak self] object in
        self?.downloadObjectPrimaryPhoto(object: object)
      },
      isImageDownloaded: downloadedImagesObjectID.contains(objects[indexPath.item].objectid))
    cell.configure(viewModel: viewModel)
    return cell
  }
  
  // MARK: - UICollectionViewDelegate
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = (collectionView.bounds.width - (config.numberOfItemsForRow + 1) * config.horizontalPadding)/config.numberOfItemsForRow
    return CGSize(width: width, height: config.cellHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    UIEdgeInsets(top: config.topPadding,
                 left: config.horizontalPadding,
                 bottom: config.bottomPadding,
                 right: config.horizontalPadding)
  }
}

extension ObjectsViewController: UIScrollViewDelegate {
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    loadNextPageIfNeeded(contentOffset: targetContentOffset.pointee)
  }
}
