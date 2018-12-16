//
//  AsyncTask.swift
//  Nomosi
//
//  Created by Mario on 16/12/2018.
//

import Foundation

public typealias ProgressCallback = (_ progress: Progress) -> Void

class AsycTask<ExpectedResult>: NSObject {
    
    typealias CompletionClosure = ((_ result: ExpectedResult,
                                    _ response: URLResponse?,
                                    _ error: Error?) -> Void)
    
    var onProgress: ProgressCallback?
    var onCompletion: CompletionClosure?
    
    public init(onProgress: ProgressCallback?,
                onCompletion: CompletionClosure?) {
        self.onProgress = onProgress
        self.onCompletion = onCompletion
    }
    
}
