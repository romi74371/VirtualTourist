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
        static let ImagePath = "imageFilePath"
    }
    
    @NSManaged var title: String?
    @NSManaged var imageURL: String?
    @NSManaged var imagePath: String?
    @NSManaged var pin: Pin?
    
    var albumImage: UIImage? {
        get {
            return FlickrClient.Caches.imageCache.imageWithIdentifier(getFilename(NSURL(string: imageURL!)!))
        }
        
        set {
            FlickrClient.Caches.imageCache.storeImage(newValue, withIdentifier: getFilename(NSURL(string: imageURL!)!))
            //let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
            //let pathArray = [dirPath, getFilename(NSURL(string: imageURL!)!)]
            //let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
            //self.imagePath = fileURL.path
        }
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        title = dictionary[Keys.Title] as? String
        imageURL = dictionary[Keys.ImageURL] as? String
    }
    
    // before delete this entity delete the image in the FS
    override func prepareForDeletion() {
        // Delete file if possible
        if let imageURL = self.imageURL {
            FlickrClient.Caches.imageCache.removeImage(getFilename(NSURL(string: imageURL)!))
        }
    }
    
    func getFilename(photoURL: NSURL) -> String {
        let components = photoURL.pathComponents
        return components!.last!
    }
    
}

