//
//  URLCache+CacheProvider.swift
//  Nomosi
//
//  Created by Mario on 07/10/2018.
//

import Foundation
import CoreData

class CoreDataManager {
    
    private let name: String
    private var storeURL: URL?
    private var container: NSPersistentContainer!
    
    init(name: String) {
        self.name = name
        initDatabase()
    }
    
    func initDatabase() {
        guard
            let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
            let modelURL = Bundle.nomosi?.url(forResource: name, withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            else { return }
        let storeURL = baseURL.appendingPathComponent("Database/\(name).sqlite")
        let container = NSPersistentContainer(name: name, managedObjectModel: managedObjectModel)
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        container.loadPersistentStores { [weak self] _, error in
            if let error = error {
                print("Fail to load persistent store - Error: \(error)")
                self?.dropDatabase()
            }
        }
        let viewContext = container.viewContext
        viewContext.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        
        self.storeURL = storeURL
        self.container = container
    }
    
    func dropDatabase() {
        defer { initDatabase() }
        guard
            let storeURL = storeURL
            else { return }
        do {
            try FileManager.default.removeItem(at: storeURL)
            try FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path+"-wal"))
            try FileManager.default.removeItem(at: URL(fileURLWithPath: storeURL.path+"-shm"))
        } catch let error {
            print(error)
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
