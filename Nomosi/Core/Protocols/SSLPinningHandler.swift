//
//  SSLPinningHandler.swift
//  Nomosi
//
//  Created by Mario on 03/10/2019.
//  Copyright © 2019 Mario Iannotta. All rights reserved.
//

import Foundation

public protocol SSLPinningHandler {
    
    func configuration(for challenge: URLAuthenticationChallenge) -> (disposition: URLSession.AuthChallengeDisposition, credentials: URLCredential?)
    
}

public struct SSLPinningLocalCertificate: SSLPinningHandler {
    
    private let certificatePath: String
    
    public init(certificatePath: String) {
        self.certificatePath = certificatePath
    }
    
    public func configuration(for challenge: URLAuthenticationChallenge) -> (disposition: URLSession.AuthChallengeDisposition, credentials: URLCredential?) {
        guard
            challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            errSecSuccess == {
                var secresult = SecTrustResultType.invalid
                return SecTrustEvaluate(serverTrust, &secresult)
            }(),
            let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
            let serverCertificateData: Data = {
                let serverCertificateData = SecCertificateCopyData(serverCertificate)
                let data = CFDataGetBytePtr(serverCertificateData)
                let size = CFDataGetLength(serverCertificateData)
                return NSData(bytes: data, length: size) as Data
            }(),
            let localCertificateData = NSData(contentsOfFile: certificatePath),
            localCertificateData.isEqual(to: serverCertificateData)
            else {
                return (.cancelAuthenticationChallenge, nil)
            }
        
        return (.useCredential, URLCredential(trust: serverTrust))
    }
    
}
