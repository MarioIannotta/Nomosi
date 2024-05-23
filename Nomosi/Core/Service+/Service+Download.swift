//
//  Service+Upload.swift
//  Nomosi
//
//  Created by Mario on 15/10/2018.
//

import Foundation

open class DownloadService: Service<URL> {

  public init(targetLocation: String) {
    super.init()
    self.downloadTargetLocation = targetLocation
    serviceType = .downloadFile
  }
}

class DownloadDelegate: AsycTask<URL>, URLSessionDownloadDelegate {
  
  // MARK: - URLSessionDownloadDelegate
  
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {
    let progress = Progress(totalUnitCount: totalBytesExpectedToWrite)
    progress.completedUnitCount = totalBytesWritten
    onProgress?(progress)
  }
  
  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didFinishDownloadingTo location: URL) {
    guard let downloadTargetLocation, let downloadTargetLocationURL = URL(string: downloadTargetLocation)
    else {
      onCompletion?(location, downloadTask.response, ServiceError.invalidDownloadTargetPath)
      return
    }
    do {
      try? FileManager.default.removeItem(at: downloadTargetLocationURL)
      try FileManager.default.copyItem(atPath: location.path, toPath: downloadTargetLocation)
      onCompletion?(downloadTargetLocationURL, downloadTask.response, downloadTask.error)
    } catch {
      onCompletion?(location, downloadTask.response, error)
    }
  }
  
  func urlSession(_ session: URLSession,
                  didReceive challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
    guard let sslPinningHandler = sslPinningHandler
    else {
      completionHandler(.performDefaultHandling, nil)
      return
    }
    let configuration = sslPinningHandler.configuration(for: challenge)
    completionHandler(configuration.disposition, configuration.credentials)
  }
}
