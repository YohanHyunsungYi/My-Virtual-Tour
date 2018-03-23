//
//  Photo+CoreDataClass.swift
//  VirtualTourist_Yohan
//
//  Created by Yohan Yi on 2017. 7. 7..
//  Copyright © 2017년 Yohan Yi. All rights reserved.
//

import Foundation
import CoreData


public class Photo: NSManagedObject {

    convenience init (_ data: NSData, _ context: NSManagedObjectContext){
        if let ent = NSEntityDescription.entity(forEntityName: "Photo", in: context) {
            self.init(entity: ent, insertInto: context)
            self.photoFromFlicker = data
        } else {
            fatalError("Unable to find Entity name!")
        }
    }
    
}
