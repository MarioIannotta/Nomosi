//
//  Service+Upload.swift
//  Nomosi
//
//  Created by Mario on 15/10/2018.
//

import Foundation

open class DownloadService: Service<URL> {
    
    public override init() {
        super.init()
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
        onCompletion?(location, downloadTask.response, downloadTask.error)
    }
    
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard
            let sslPinningHandler = sslPinningHandler
            else {
                completionHandler(.performDefaultHandling, nil)
                return
            }
        let configuration = sslPinningHandler.configuration(for: challenge)
        completionHandler(configuration.disposition, configuration.credentials)
    }
}
