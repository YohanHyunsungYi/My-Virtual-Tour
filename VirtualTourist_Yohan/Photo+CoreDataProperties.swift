//
//  Photo+CoreDataProperties.swift
//  VirtualTourist_Yohan
//
//  Created by Yohan Yi on 2017. 7. 7..
//  Copyright © 2017년 Yohan Yi. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var photoFromFlicker: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin_Coredata?

}
