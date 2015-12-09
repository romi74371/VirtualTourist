//
//  AlbumViewController.swift
//  VirtualTourist
//
//  Created by Roman Hauptvogel on 07/11/15.
//  Copyright © 2015 Roman Hauptvogel. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class AlbumViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    var pin: Pin!
    var latitudeDelta: Double = 0.1
    var longitudeDelta: Double = 0.1
    
    var insertedIndexPaths: [NSIndexPath]!
    var deletedIndexPaths : [NSIndexPath]!
    var updatedIndexPaths : [NSIndexPath]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newDownloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.newDownloadButton.hidden = false
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.mapView.delegate = self
        self.mapView.userInteractionEnabled = false
        self.mapView.region.center = pin!.coordinate
        self.mapView.region.span = MKCoordinateSpan(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta)
        self.mapView.addAnnotation(pin!)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {}
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //if (pin.pendingDownloads == 0) {
        //    self.newDownloadButton.hidden = false
        //}

        if (pin.photos!.isEmpty) {
            //if (Int(pin.pendingDownloads!) > 0) {
              loadData()
            //} else {
            //    let alertController = UIAlertController(title: "Alert", message:
            //        "There are no photos in current album!", preferredStyle: UIAlertControllerStyle.Alert)
            //    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
            //    self.presentViewController(alertController, animated: true, completion: nil)
            //}
        }
    }
    
    @IBAction func newDownloadTouchUpInside(sender: AnyObject) {
        for photo in fetchedResultsController.fetchedObjects as! [Photo]{
            FlickrClient.Caches.imageCache.removeImage(NSURL(string: photo.imageURL!)!.lastPathComponent!)
            pin.deletePhoto(photo)
            CoreDataStackManager.sharedInstance().saveContext()
        }
        loadData()
    }
    
    // MARK: = load data
    
    func loadData() {
        FlickrClient.sharedInstance().getPhotos(pin) { (success, result, totalPhotos, totalPages, errorString) in
            if (success == true) {
                print("\(totalPhotos) photos have been found!")
                //print(result)
                
                // Parse the array of photo dictionaries
                let _ = result!.map() { (dictionary: [String : AnyObject]) -> Photo in
                    let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                    photo.pin = self.pin
                    CoreDataStackManager.sharedInstance().saveContext()
                    
                    return photo
                }
                
                // Update the collection view on the main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.collectionView.reloadData()
                }
            } else {
                print("Finding photos error!")
            }
        }
    }
    
    // MARK: - Configure Cell
    
    func configureCell(cell: PhotoCollectionViewCell, photo: Photo) {
        var cellImage = UIImage(named: "posterPlaceHolder")
        
        //cell.textLabel!.text = photo.title
        cell.imageView!.image = nil
        cell.activityIndicator.hidden = true
        
        //print("configure \(photo)")
        
        // Set the Movie Poster Image
        if photo.imageURL == nil || photo.imageURL == "" {
            cellImage = UIImage(named: "noImage")
        } else if photo.albumImage != nil {
            cellImage = photo.albumImage
        } else { // This is the interesting case. The pin has an image name, but it is not downloaded yet.
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            
            FlickrClient.sharedInstance().getPhoto(NSURL(string: photo.imageURL!)!) { (success, result, errorString) in
                if (success == true) {
                    // update the model, so that the infrmation gets cashed
                    photo.albumImage = result
                    //self.pin.pendingDownloads--
                    //CoreDataStackManager.sharedInstance().saveContext()
                    
                    //if (self.pin.pendingDownloads == 0) {
                    //    dispatch_async(dispatch_get_main_queue(), {
                    //        let alertController = UIAlertController(title: "Alert", message:
                    //            "All photos have been downloaded", preferredStyle: UIAlertControllerStyle.Alert)
                    //        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    //        self.presentViewController(alertController, animated: true, completion: nil)
                    //
                    //        self.newDownloadButton.hidden = false
                    //    })
                    //}
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.imageView!.image = result
                        
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                    })
                } else {
                    print(errorString)
                }
            }
            //CoreDataStackManager.sharedInstance().saveContext()
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            //cell.taskToCancelifCellIsReused = task
        }
        
        cell.imageView!.image = cellImage
    }
    
    // MARK: - Core Data Convenience.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // lazy fetchedResultsController property
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.sortDescriptors = []
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionInfo = self.fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        configureCell(cell, photo: photo)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        // Delete image
        let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        self.pin.deletePhoto(photo)
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        insertedIndexPaths = [NSIndexPath]()
        deletedIndexPaths  = [NSIndexPath]()
        updatedIndexPaths  = [NSIndexPath]()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
            switch type {
                case .Insert:
                    //print("insert")
                    //self.collectionView.insertItemsAtIndexPaths([newIndexPath!])
                    insertedIndexPaths.append(newIndexPath!)
                case .Delete:
                    //print("delete")
                    //self.collectionView.deleteItemsAtIndexPaths([indexPath!])
                    deletedIndexPaths.append(indexPath!)
                case .Update:
                    //print("uptade")
                    //self.collectionView.reloadItemsAtIndexPaths([indexPath!])
                    updatedIndexPaths.append(indexPath!)
                default:
                    break
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Perform updates into the collectionView
        collectionView.performBatchUpdates({() -> Void in
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItemsAtIndexPaths([indexPath])
            }
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItemsAtIndexPaths([indexPath])
            }
        }, completion: nil)
    }
}
