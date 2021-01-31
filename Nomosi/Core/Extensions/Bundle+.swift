//
//  Bundle+.swift
//  Nomosi
//
//  Created by Mario on 05/09/2019.
//  Copyright © 2019 Mario Iannotta. All rights reserved.
//

import Foundation

extension Bundle {
    
    static var nomosi: Bundle? = {
        // TODO: Find a better there's a better way to do this
        [Bundle.main.resourceURL?.deletingLastPathComponent().path,  /* catalyst */
                         Bundle.main.resourcePath /* iOS  */ ]
            .compactMap { $0?.appending("/Frameworks/Nomosi.framework") }
            .compactMap(Bundle.init)
            .first
    }()
}
