//
//  NSPersistentContainer+Bundle.swift
//  Nomosi
//
//  Created by Mario on 07/04/2019.
//

import CoreData

extension NSPersistentContainer {
    
    public convenience init(name: String, bundle: Bundle) {
        guard
            let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Unable to located Core Data model")
            }
        
        self.init(name: name, managedObjectModel: mom)
    }
    
}
