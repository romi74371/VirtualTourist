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
        static let CurrentPage = "currentPage"
        static let TotalPages = "totalPages"
    }
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: [Photo]?
    
    @NSManaged var currentPage: Int16
    @NSManaged var totalPages: Int16
    @NSManaged var pendingDownloads: Int16
    
    var title: String? = "View album"
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        latitude = dictionary[Keys.Latitude] as! Double
        longitude = dictionary[Keys.Longitude] as! Double
        
        currentPage = 1
        pendingDownloads = Int16(FlickrClient.Constants.PER_PAGE)!
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
    
    // Delete all pin's photos
    func deletePhotos() {
        if let photos = self.photos {
            for photo in photos {
                deletePhoto(photo)
            }
        }
        pendingDownloads = Int16(FlickrClient.Constants.PER_PAGE)!
    }
    
    // Delete one pin photo
    func deletePhoto(photo: Photo) {
        photo.pin = nil
        sharedContext.deleteObject(photo)
    }
}
