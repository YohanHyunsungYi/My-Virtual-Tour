//
//  MapPin.swift
//  VirtualTourist_Yohan
//
//  Created by Yohan Yi on 2017. 7. 3..
//  Copyright © 2017년 Yohan Yi. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
