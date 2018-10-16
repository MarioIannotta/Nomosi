//
//  Service+Upload.swift
//  Nomosi
//
//  Created by Mario on 15/10/2018.
//

import Foundation

public typealias ProgressCallback = (_ progress: Progress) -> Void

class UploadDelegate: NSObject {
    
    typealias CompletionClosure = ((_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void)
    
    private var onProgress: ProgressCallback?
    private var onCompletion: CompletionClosure?
    private var data: Data?
    
    init(onProgress: ProgressCallback?,
         onCompletion: CompletionClosure?) {
        self.onProgress = onProgress
        self.onCompletion = onCompletion
    }
    
}

extension UploadDelegate: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        let progress = Progress(totalUnitCount: totalBytesExpectedToSend)
        progress.completedUnitCount = totalBytesSent
        onProgress?(progress)
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        onCompletion?(data, task.response, error)
    }
    
}

extension UploadDelegate: URLSessionDataDelegate {
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data = data
    }
    
}
