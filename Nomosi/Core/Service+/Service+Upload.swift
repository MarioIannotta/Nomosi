//
//  Service+Upload.swift
//  Nomosi
//
//  Created by Mario on 15/10/2018.
//

import Foundation

class UploadDelegate: AsycTask<Data?>, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    private var data: Data?
    
    // MARK: - URLSessionTaskDelegate
    
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
    
    // MARK: - URLSessionDataDelegate
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        self.data = data
    }
    
}
