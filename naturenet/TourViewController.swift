//
//  TourViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/22/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import MapKit

class TourViewController: UIViewController, MKMapViewDelegate, UINavigationControllerDelegate,
                        UIImagePickerControllerDelegate {

    @IBOutlet weak var acesMapView: MKMapView!
    
    var locationIconNames = ["number1", "number2", "number3", "number4", "number5", "number6", "number7",
                                "number8", "number9", "number10", "number11"]
    var tourAnnotations: [TourLocationAnnotation]?
    var cameraImage: UIImage?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initMap()
        self.tourAnnotations = getTourAnnotations()
        for location in self.tourAnnotations! {
            setAnnotation(location)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMap() {
        // request to authorize to use location
        locationManager.requestAlwaysAuthorization()
        var latitude: CLLocationDegrees = 39.195998
        var longitude: CLLocationDegrees = -106.821823
        var latDelta: CLLocationDegrees = 0.0005
        var lonDelta: CLLocationDegrees = 0.0005
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        acesMapView.setRegion(region, animated: true)
        acesMapView.mapType = MKMapType.Satellite
        acesMapView.showsUserLocation = true
    }
    
    func setAnnotation(annotation: TourLocationAnnotation) {
        self.acesMapView.addAnnotation(annotation)
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // mapView setup functions
    //----------------------------------------------------------------------------------------------------------------------
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is TourLocationAnnotation) {
            return nil
        }
        
        let reuseId = "customAnnotationView"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView.canShowCallout = true
        }
        else {
            anView.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as TourLocationAnnotation
        anView.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIButton
        anView.image = UIImage(named: cpa.imageName)
        return anView
        
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
            self.performSegueWithIdentifier("tourToDetail", sender: view)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tourToDetail" {
            let detailVC = segue.destinationViewController as LocationDetailViewController
            // if passed from a cell
            if let annotationView = sender as? MKAnnotationView {
                let annotation = annotationView.annotation as TourLocationAnnotation
                detailVC.locationTitle = annotation.title
                detailVC.locationDescription = annotation.subtitle
            }
        }
        if segue.identifier == "tourToObservationDetail" {
            let detailVC = segue.destinationViewController as ObservationDetailController
            detailVC.imageFromObservation = ObservationsController.PickedImage(image: self.cameraImage, isFromGallery: false)
            detailVC.sourceViewController = NSStringFromClass(TourViewController)
        }
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // pick from camera or gallary
    //----------------------------------------------------------------------------------------------------------------------
    @IBAction func openCamera() {
        var picker:UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            openGallary(picker)
        }
    }
    
    func openGallary(picker: UIImagePickerController!) {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.performSegueWithIdentifier("tourToObservationDetail", sender: self)
    }
    
    
    // given latitude and longtitude, return CLLocationCoordinate2D
    func coordinatesToLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                    latDelta: CLLocationDegrees, lonDelta: CLLocationDegrees) -> CLLocationCoordinate2D {
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        return location
    }
    
    func getTourAnnotations() -> [TourLocationAnnotation] {
        var latNumber: CLLocationDegrees?
        var lonNumber: CLLocationDegrees?
        var tourAnnotations = [TourLocationAnnotation] ()
        if let site = Session.getSite() {
            var landmarks = site.getLandmarks()
            for landmark in landmarks {
                var extras = landmark.extras
                var tourAnnotation = TourLocationAnnotation()
                tourAnnotation.title = landmark.title
                // because entry "Other" has no extras, no description
                if extras.isEmpty {
                    continue
                }
                var coordinate = extras.componentsSeparatedByString(",") as [String]
                var latCoordinate = coordinate[0].componentsSeparatedByString(":") as [String]
                var lonCoordinate = coordinate[1].componentsSeparatedByString(":") as [String]
                latNumber = (latCoordinate[1] as NSString).doubleValue
                lonNumber = (lonCoordinate[1] as NSString).doubleValue
                var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latNumber!, lonNumber!)
                // println("location \(location.latitude) \(location.longitude)")
                tourAnnotation.subtitle = landmark.context_description
                tourAnnotation.coordinate = location
                
                var title = landmark.title.componentsSeparatedByString(".")
                if let iconIndex = title[0].toInt() {
                    tourAnnotation.imageName = self.locationIconNames[iconIndex - 1]
                }
                tourAnnotations.append(tourAnnotation)
            }
        }
        return tourAnnotations
    }
    
    class TourLocationAnnotation: MKPointAnnotation {
        var imageName: String!
    }
}
