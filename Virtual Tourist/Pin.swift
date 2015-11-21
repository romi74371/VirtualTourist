//
//  Pin.swift
//  VirtualTourist
//
//  Created by Roman Hauptvogel on 07/11/15.
//  Copyright © 2015 Roman Hauptvogel. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@objc(Pin)

class Pin : NSManagedObject, MKAnnotation {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]?
    
    var title: String? = "View album"
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
    }
    
    // MARK - MKAnnotation
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func setCoordinate(newCoordinate: CLLocationCoordinate2D) {
        willChangeValueForKey("coordinate")
        self.latitude = newCoordinate.latitude
        self.longitude = newCoordinate.longitude
        didChangeValueForKey("coordinate")
    }
    
    lazy var sharedContext: NSManagedObjectContext! = {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }()
    
    // Delete all pin's photos and then save
    func deletePinPhotosAndSave() {
        if let photos = self.photos {
            for photo in photos {
                deletePhoto(photo)
            }
        }
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // Only delete the photo
    func deletePhoto(photo: Photo) {
        photo.pin = nil
        sharedContext.deleteObject(photo)
    }
}
