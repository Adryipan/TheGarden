//
//  Plant+CoreDataProperties.swift
//  ApiTestWithCoreData
//
//  Created by Adrian Yip on 12/9/20.
//  Copyright © 2020 Monash University. All rights reserved.
//
//

import Foundation
import CoreData


extension Plant {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }

    @NSManaged public var commonName: String?
    @NSManaged public var scientificName: String?
    @NSManaged public var family: String?
    @NSManaged public var image_url: String?
    @NSManaged public var year: String?
    @NSManaged public var exhibitions: NSSet?

}

// MARK: Generated accessors for exhibitions
extension Plant {

    @objc(addExhibitionsObject:)
    @NSManaged public func addToExhibitions(_ value: Exhibition)

    @objc(removeExhibitionsObject:)
    @NSManaged public func removeFromExhibitions(_ value: Exhibition)

    @objc(addExhibitions:)
    @NSManaged public func addToExhibitions(_ values: NSSet)

    @objc(removeExhibitions:)
    @NSManaged public func removeFromExhibitions(_ values: NSSet)

}
