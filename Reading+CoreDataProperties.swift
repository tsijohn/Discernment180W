//
//  Reading+CoreDataProperties.swift
//  
//
//  Created by John Kim on 1/10/25.
//
//

import Foundation
import CoreData


extension Reading {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reading> {
        return NSFetchRequest<Reading>(entityName: "Reading")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var dayNumber: Int16
    @NSManaged public var content: String?

}
