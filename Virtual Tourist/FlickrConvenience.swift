//
//  FlickrConvenience.swift
//  VirtualTourist
//
//  Created by Roman Hauptvogel on 11/11/15.
//  Copyright © 2015 Roman Hauptvogel. All rights reserved.
//

import UIKit
import Foundation
import MapKit

// MARK: - Convenient Resource Methods

extension FlickrClient {
    
    // MARK: - GET Convenience Methods
    
    func getPhotos(latitude: Double, longitude: Double, completionHandler: (success: Bool, photos: [[String: AnyObject]]?, totalPhotos: Int, totalPages: Int, errorString: String?) -> Void) {
    
        let methodArguments = [
            "method": Methods.search,
            "bbox": createBoundingBoxString(latitude, longitude: longitude),
            "safe_search": Constants.SAFE_SEARCH,
            "extras": Constants.EXTRAS,
            "format": Constants.DATA_FORMAT,
            "nojsoncallback": Constants.NO_JSON_CALLBACK,
            "per_page": Constants.PER_PAGE
        ]
        
        taskForGETMethod("", parameters: methodArguments) { data, error in
            if let _ = error {
                completionHandler(success: false, photos: nil, totalPhotos: 0, totalPages: 0, errorString: "Get Photo Failed.")
            } else {
                if let photosDictionary = data!.valueForKey("photos") as? [String:AnyObject] {
                    
                    var totalPhotosVal = 0
                    if let totalPhotos = photosDictionary["total"] as? String {
                        totalPhotosVal = (totalPhotos as NSString).integerValue
                    }
                    
                    var totalPagesVal = 0
                    if let totalPages = photosDictionary["pages"] as? String {
                        totalPagesVal = (totalPages as NSString).integerValue
                    }
                    
                    if totalPhotosVal > 0 {
                        if let photosArray = photosDictionary["photo"] as? [[String: AnyObject]] {
                            completionHandler(success: true, photos: photosArray, totalPhotos: totalPhotosVal, totalPages: totalPagesVal, errorString: nil)
                            print("total: \(totalPhotosVal) pages: \(totalPagesVal)")
                        } else {
                            print("Cant find key 'photo' in \(photosDictionary)")
                            completionHandler(success: false, photos: nil, totalPhotos: 0, totalPages: 0, errorString: "Cant find key 'photo'.")
                        }
                    } else {
                        
                    }
                } else {
                    print("Cant find key 'photos'")
                    completionHandler(success: false, photos: nil, totalPhotos: 0, totalPages: 0, errorString: "Cant find key 'photos'.")
                }
            }
        }
    }
    
    func getPhoto(photoURL: NSURL, completionHandler: (success: Bool, photo: UIImage, errorString: String?) -> Void) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            if let imageData = NSData(contentsOfURL: photoURL) {
                completionHandler(success: true, photo: UIImage(data: imageData)!, errorString: nil)
            } else {
                completionHandler(success: false, photo: UIImage(), errorString: "Image does not exist at \(photoURL)")
            }
        }
    }
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottom_left_lat = max(latitude - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon = min(longitude + Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MAX)
        let top_right_lat = min(latitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
}

