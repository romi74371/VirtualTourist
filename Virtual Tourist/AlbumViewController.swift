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
    
    var photos: [[String: AnyObject]]!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.mapView.delegate = self
        self.collectionView.dataSource = self
        
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
        
        if pin.photos!.isEmpty {
            loadData()
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = MKPinAnnotationView.greenPinColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
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
        
        // Here is how to replace the actors array using objectAtIndexPath
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PhotoCollectionViewCell", forIndexPath: indexPath) as! PhotoCollectionViewCell
        
        // This is the new configureCell method
        configureCell(cell, photo: photo)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        //let cell = collectionView.cellForItemAtIndexPath(indexPath) as! UICollectionViewCell
        
        // Delete image
        //let photo = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        // Only remove ready or failed images
        //if photo.imageState != Photo.State.New {
        //    photoService.deletePhotoAndSave(photo)
        //} else {
        //    showMessageWithTitle("Operation not allowed", message: "You can't delete a photo while it is downloading")
        //}
        
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    // Step 4: This would be a great place to add the delegate methods
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        //self.collectionView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                //self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                print("insert")
            case .Delete:
                //self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
                print("delete")
            default:
                return
            }
    }
    
    //
    // This is the most interesting method. Take particular note of way the that newIndexPath
    // parameter gets unwrapped and put into an array literal: [newIndexPath!]
    //
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                //tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                print("insert2")
                
            case .Delete:
                //tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                print("delete2")
                
            case .Update:
                //let cell = tableView.cellForRowAtIndexPath(indexPath!) as! ActorTableViewCell
                //let movie = controller.objectAtIndexPath(indexPath!) as! Movie
                //self.configureCell(cell, movie: movie)
                print("uptade2")
                
            case .Move:
                //tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
                //tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
                print("move2")
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        //self.collectionView.endUpdates()
    }
    
    func loadData() {
        FlickrClient.sharedInstance().getPhotos(pin.latitude, longitude: pin.longitude) { (success, result, totalPhotos, totalPages, errorString) in
            if (success == true) {
                print("Photos have been found!")
                
                // Parse the array of photo dictionaries
                let _ = result!.map() { (dictionary: [String : AnyObject]) -> Photo in
                    let photo = Photo(dictionary: dictionary, context: self.sharedContext)
                    photo.pin = self.pin
                    
                    return photo
                }
                
                // Update the table on the main thread
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
        var cellImage = UIImage(named: "posterPlaceHoldr")
        
        //cell.textLabel!.text = photo.title
        cell.imageView!.image = nil
        cell.activityIndicator.hidden = true
        
        print("configure \(photo)")
        
        // Set the Movie Poster Image
        if photo.imageURL == nil || photo.imageURL == "" {
            cellImage = UIImage(named: "noImage")
        //} else if photo.imageFilename != nil {
        //    cellImage = photo.albumImage
        } else { // This is the interesting case. The pin has an image name, but it is not downloaded yet.
            cell.activityIndicator.hidden = false
            cell.activityIndicator.startAnimating()
            
            FlickrClient.sharedInstance().getPhoto(NSURL(string: photo.imageURL!)!) { (success, result, errorString) in
                if (success == true) {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.imageView!.image = result
                        
                        cell.activityIndicator.stopAnimating()
                        cell.activityIndicator.hidden = true
                    })
                } else {
                    print(errorString)
                }
            }
            // This is the custom property on this cell. See TaskCancelingTableViewCell.swift for details.
            //cell.taskToCancelifCellIsReused = task
        }
        
        //cell.imageView!.image = cellImage
    }
}
