//
//  Map.swift
//  VirtualTourist
//
//  Created by Roman Hauptvogel on 08/11/15.
//  Copyright © 2015 Roman Hauptvogel. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@objc(Map)

class Map : NSManagedObject {
    
    struct Keys {
        static let CenterLatitude = "center_latitude"
        static let CenterLongitude = "center_longitude"
        static let SpanLatitude = "span_latitude"
        static let SpanLongitude = "span_longitude"
    }
    
    @NSManaged var center_latitude: Double
    @NSManaged var center_longitude: Double
    @NSManaged var span_latitude: Double
    @NSManaged var span_longitude: Double
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Map", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        center_latitude = dictionary[Keys.CenterLatitude] as! Double
        center_longitude = dictionary[Keys.CenterLongitude] as! Double
        span_latitude = dictionary[Keys.SpanLatitude] as! Double
        span_longitude = dictionary[Keys.SpanLongitude] as! Double
    }
}
