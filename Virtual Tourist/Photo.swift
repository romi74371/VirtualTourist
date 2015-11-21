//
//  Photo.swift
//  VirtualTourist
//
//  Created by Roman Hauptvogel on 11/11/15.
//  Copyright © 2015 Roman Hauptvogel. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    
    struct Keys {
        static let Id = "id"
        static let Title = "title"
        static let ImageURL = "url_m"
        static let ImagePath = "imagePath"
    }
    
    @NSManaged var title: String?
    @NSManaged var imageURL: String?
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        title = dictionary[Keys.Title] as? String
        imageURL = dictionary[Keys.ImageURL] as? String
        //imagePath = dictionary[Keys.ImagePath] as? String
    }
    
    var albumImage: UIImage? {
        
        get {
            //return TheMovieDB.Caches.imageCache.imageWithIdentifier(posterPath)
            return nil
        }
        
        set {
            //TheMovieDB.Caches.imageCache.storeImage(newValue, withIdentifier: posterPath!)
        }
    }
    
}

