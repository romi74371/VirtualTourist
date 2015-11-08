//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Roman Hauptvogel on 07/11/15.
//  Copyright © 2015 Roman Hauptvogel. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        
        // Step 2: invoke fetchedResultsController.performFetch(nil) here
        do {
            try fetchedResultsController.performFetch()
        } catch {}
        
        // Step 9: set the fetchedResultsController.delegate = self
        fetchedResultsController.delegate = self
    
        self.mapView.addAnnotations(fetchedResultsController.fetchedObjects as! [MKAnnotation])
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "dropPin:")
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
    }

    func dropPin(gestureRecognizer:UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.locationInView(self.mapView)
        let newCoord:CLLocationCoordinate2D = mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
        
        // Debugging output
        print("new pin added, latitude: \(newCoord.latitude), id: \(newCoord.longitude)")
        
        // save the pin location
        var locationDictionary = [String : AnyObject]()
        locationDictionary[Pin.Keys.Latitude] = newCoord.latitude
        locationDictionary[Pin.Keys.Longitude] = newCoord.longitude
        let pin = Pin(dictionary: locationDictionary, context: sharedContext)
        mapView.addAnnotation(pin)
        
        CoreDataStackManager.sharedInstance().saveContext()
    }
    
    // MARK: - Core Data Convenience. This will be useful for fetching. And for adding and saving objects as well.
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
    
    // Step 1 - Add the lazy fetchedResultsController property. See the reference sheet in the lesson if you
    // want additional help creating this property.
    lazy var fetchedResultsController: NSFetchedResultsController = {
        
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "latitude", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
            managedObjectContext: self.sharedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        return fetchedResultsController
        
    }()

    // MARK: - MKMapViewDelegate
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("AlbumViewController") as! AlbumViewController
        self.navigationController!.pushViewController(controller, animated: true)
    }
    
    //func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
    //    let reuseId = "pin"
        
    //    let pin = fetchedResultsController.objectAtIndexPath(indexPath) as! Pin
        
    //    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
    //    if pinView == nil {
    //        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
    //        pinView!.canShowCallout = true
    //        pinView!.pinTintColor = MKPinAnnotationView.greenPinColor()
    //        pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
    //    }
    //    else {
    //        pinView!.annotation = annotation
    //    }
        
    //    return pinView
    //}
    
    // MARK: - NSFetchedResultsControllerDelegate methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("controllerWillChangeContent")
    }
    func controller(controller: NSFetchedResultsController,
        didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
        atIndex sectionIndex: Int,
        forChangeType type: NSFetchedResultsChangeType) {
            
            switch type {
            case .Insert:
                print("insert")
                
            case .Delete:
                print("delete")
                
            default:
                return
            }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
            switch type {
            case .Insert:
                print("insert2")
                
            case .Delete:
                print("delete2")
                
            case .Update:
                print("update2")
                
            case .Move:
                print("move2")
                
            default:
                return
            }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("controllerDidChangeContent")
    }
}

