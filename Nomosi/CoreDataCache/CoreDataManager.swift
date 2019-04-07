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
        let subspecBundleURL = Bundle(for: CoreDataManager.self)
            .bundleURL
            .appendingPathComponent("CoreDataCache.bundle")
        guard
            let bundle = Bundle(url: subspecBundleURL),
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
        self.container = NSPersistentContainer(name: name, bundle: bundle)
        
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
    
    func newCachedResponse(configurationClosure: ((_ cachedResponse: CachedResponse) -> Void)) {
        let context = container.newBackgroundContext()
        let cachedResponse = CachedResponse(context: context)
        configurationClosure(cachedResponse)
        do {
            try context.save()
        } catch let error {
            print("Can't store cached response. Error: \(error)")
        }
    }
    
    func fetchCachedResponse(withIdentifier cacheIdentifier: String) -> (expirationDate: Date, cachedData: Data)? {
        let context = container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<CachedResponse> = CachedResponse.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "id = %@", cacheIdentifier)
        do {
            let result = (try context.fetch(fetchRequest)).first
            guard
                let expirationDate = result?.expirationDate as Date?,
                let cachedData = result?.data as Data?
                else {
                    return nil
                }
                return (expirationDate, cachedData)
        } catch let error {
            print("Error fetching the cached response. Error: \(error)")
            return nil
        }
    }
    
    func removeCacheResponse(withIdentifier cacheIdentifier: String) {
        let context = container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<CachedResponse> = CachedResponse.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id = %@", cacheIdentifier)
        do {
            let results = try context.fetch(fetchRequest)
            results.forEach { result in
                context.delete(result)
            }
            try context.save()
        } catch let error {
            print("Error removing cached responses. Error: \(error)")
        }
    }
    
    func removeExpiredCachedResponses() {
        let context = container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<CachedResponse> = CachedResponse.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "expirationDate < %@", NSDate())
        do {
            let results = try context.fetch(fetchRequest)
            results.forEach { result in
                context.delete(result)
            }
            try context.save()
        } catch let error {
            print("Error removing cached responses. Error: \(error)")
        }
    }
    
}
