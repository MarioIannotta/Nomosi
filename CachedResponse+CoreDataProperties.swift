//
//  CachedResponse+CoreDataProperties.swift
//  Nomosi
//
//  Created by Mario on 05/04/2019.
//
//

import Foundation
import CoreData


extension CachedResponse {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedResponse> {
        return NSFetchRequest<CachedResponse>(entityName: "CachedResponse")
    }

    @NSManaged public var date: NSDate?
    @NSManaged public var expirationDate: NSDate?
    @NSManaged public var id: String?

}
