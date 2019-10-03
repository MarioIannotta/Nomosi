//
//  AsyncTask.swift
//  Nomosi
//
//  Created by Mario on 16/12/2018.
//

import Foundation

public typealias ProgressClosure = (_ progress: Progress) -> Void

class AsycTask<ExpectedResult>: NSObject {
    
    typealias CompletionClosure = ((_ result: ExpectedResult,
                                    _ response: URLResponse?,
                                    _ error: Error?) -> Void)
    
    var onProgress: ProgressClosure?
    var onCompletion: CompletionClosure?
    var sslPinningHandler: SSLPinningHandler?
    
    public init(onProgress: ProgressClosure?,
                onCompletion: CompletionClosure?,
                sslPinningHandler: SSLPinningHandler?) {
        self.onProgress = onProgress
        self.onCompletion = onCompletion
        self.sslPinningHandler = sslPinningHandler
    }
    
}
