//
//  Bundle+.swift
//  Nomosi
//
//  Created by Mario on 05/09/2019.
//  Copyright © 2019 Mario Iannotta. All rights reserved.
//

import Foundation

extension Bundle {
    
    static var nomosi: Bundle = {
        guard
            let frameworkBundlePath = Bundle.main.resourcePath?.appending("/Frameworks/Nomosi.framework"),
            let bundle = Bundle(path: frameworkBundlePath)
            else {
                fatalError("Unable to locate Nomosi.framework")
            }
        return bundle
    }()
}
