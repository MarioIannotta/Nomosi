//
//  URLCache+CacheProvider.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import Foundation
import CoreData

class CoreDataManager {
    
    fileprivate var container: NSPersistentContainer!
    fileprivate var storeURL: URL?
    fileprivate var name = ""
    
    init(name: String) {
        self.name = name
        initDatabase()
    }
    
    func initDatabase() {
        guard
            let storeURL = FileManager
                .default
                .urls(for: .documentDirectory, in: .userDomainMask)
                .last?
                .appendingPathComponent("\(name).sqlite")
            else {
                print("Can't find a valid store named \(name)")
                return
            }
        self.storeURL = storeURL
        self.container = NSPersistentContainer(name: name)
        
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = storeURL
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        container.loadPersistentStores { storesDescription, error in
            if let error = error {
                print("Fail to load persistent store - Error: \(error)")
            }
        }
    }
    
    func test() {
        
        CachedResponse
    }
    
}
