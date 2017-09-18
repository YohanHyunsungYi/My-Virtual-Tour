//
//  StoredLocation+CoreDataProperties.swift
//  VirtualTourist_Yohan
//
//  Created by Yohan Yi on 2017. 7. 7..
//  Copyright © 2017년 Yohan Yi. All rights reserved.
//

import Foundation
import CoreData


extension StoredLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoredLocation> {
        return NSFetchRequest<StoredLocation>(entityName: "StoredLocation")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var span1: Double
    @NSManaged public var span2: Double

}
