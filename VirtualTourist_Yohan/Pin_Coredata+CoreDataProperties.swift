//
//  Pin_Coredata+CoreDataProperties.swift
//  VirtualTourist_Yohan
//
//  Created by Yohan Yi on 2017. 7. 7..
//  Copyright © 2017년 Yohan Yi. All rights reserved.
//

import Foundation
import CoreData


extension Pin_Coredata {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Pin_Coredata> {
        return NSFetchRequest<Pin_Coredata>(entityName: "Pin_Coredata")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var photos: NSSet?

}

// MARK: Generated accessors for photos
extension Pin_Coredata {

    @objc(addPhotosObject:)
    @NSManaged public func addToPhotos(_ value: Photo)

    @objc(removePhotosObject:)
    @NSManaged public func removeFromPhotos(_ value: Photo)

    @objc(addPhotos:)
    @NSManaged public func addToPhotos(_ values: NSSet)

    @objc(removePhotos:)
    @NSManaged public func removeFromPhotos(_ values: NSSet)

}
