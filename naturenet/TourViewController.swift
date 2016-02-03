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
                        UIImagePickerControllerDelegate, APIControllerProtocol {

    @IBOutlet weak var acesMapView: MKMapView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    
    var site: Site!
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
        if #available(iOS 8.0, *) {
            locationManager.requestAlwaysAuthorization()
        } else {
            // Fallback on earlier versions
        }
        let latitude: CLLocationDegrees = 39.195998
        let longitude: CLLocationDegrees = -106.821823
        let latDelta: CLLocationDegrees = 0.0005
        let lonDelta: CLLocationDegrees = 0.0005
        let span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        acesMapView.setRegion(region, animated: true)
        acesMapView.mapType = MKMapType.Satellite
        acesMapView.showsUserLocation = true
        
        // programmatically add locaiton, camera, refresh buttonBarItems
        let locationBtnItem = MKUserTrackingBarButtonItem(mapView: self.acesMapView)
        let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: self, action: nil)
        let cameraItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "openCamera")
        let refreshItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshLocations")
        let items: [UIBarButtonItem] = [locationBtnItem, flexibleSpaceItem, cameraItem, flexibleSpaceItem, refreshItem]
        self.toolBar.setItems(items, animated: true)
    }
    
    func setAnnotation(annotation: TourLocationAnnotation) {
        self.acesMapView.addAnnotation(annotation)
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // mapView setup functions
    //----------------------------------------------------------------------------------------------------------------------
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is TourLocationAnnotation) {
            return nil
        }
        
        let reuseId = "customAnnotationView"
        
        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! TourLocationAnnotation
        anView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        anView!.image = UIImage(named: cpa.imageName)
        return anView
        
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        self.performSegueWithIdentifier("tourToDetail", sender: view)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "tourToDetail" {
            let detailVC = segue.destinationViewController as! LocationDetailViewController
            // if passed from a cell
            if let annotationView = sender as? MKAnnotationView {
                let annotation = annotationView.annotation as! TourLocationAnnotation
                detailVC.locationTitle = annotation.title
                detailVC.locationDescription = annotation.subtitle
            }
        }
        if segue.identifier == "tourToObservationDetail" {
            let detailVC = segue.destinationViewController as! ObservationDetailController
            detailVC.imageFromObservation = ObservationsController.PickedImage(image: self.cameraImage, isFromGallery: false)
            detailVC.sourceViewController = NSStringFromClass(TourViewController)
        }
    }
    
    func refreshLocations() {
        let parseService = APIService()
        parseService.delegate = self
        Site.doPullByNameFromServer(parseService, name: "aces")
    }
    
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            let status = response["status_code"] as! Int
            if (status == 400) {
                let errorMessage = "We didn't recognize your NatureNet Name or Password"
                print(errorMessage)
                return
            }
            
            // 600 is self defined error code on the phone's side
            if (status == 600) {
                let errorMessage = "Internet seems not working"
                print(errorMessage)
                return
            }
            
            if from == "Site" {
                let data = response["data"] as! NSDictionary!
                let predicate = NSPredicate(format: "name = %@", "aces")
                let exisitingSite = NNModel.fetechEntitySingle(NSStringFromClass(Site), predicate: predicate) as? Site
                if exisitingSite != nil {
                    // println("You have aces site in core data: "  + exisitingSite!.toString())
                    // should check if modified date is changed here!! but no modified date returned from API
                    self.site = exisitingSite
                    self.site?.updateToCoreData(data)
                } else {
                    self.site = Site.saveToCoreData(data)
                }
                // update annotations on the map
                self.tourAnnotations = self.getTourAnnotations()
                self.acesMapView.removeAnnotations(self.acesMapView.annotations)
                for location in self.tourAnnotations! {
                    self.setAnnotation(location)
                }
            }

        })
    }

    //----------------------------------------------------------------------------------------------------------------------
    // pick from camera or gallary
    //----------------------------------------------------------------------------------------------------------------------
    @IBAction func openCamera() {
        let picker:UIImagePickerController = UIImagePickerController()
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
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.performSegueWithIdentifier("tourToObservationDetail", sender: self)
    }
    
    
    // given latitude and longtitude, return CLLocationCoordinate2D
    func coordinatesToLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                    latDelta: CLLocationDegrees, lonDelta: CLLocationDegrees) -> CLLocationCoordinate2D {
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        return location
    }
    
    func getTourAnnotations() -> [TourLocationAnnotation] {
        var latNumber: CLLocationDegrees?
        var lonNumber: CLLocationDegrees?
        var tourAnnotations = [TourLocationAnnotation] ()
        if let site = Session.getSite() {
            let landmarks = site.getLandmarks()
            for landmark in landmarks {
                let extras = landmark.extras
                let tourAnnotation = TourLocationAnnotation()
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
                let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latNumber!, lonNumber!)
                // println("location \(location.latitude) \(location.longitude)")
                tourAnnotation.subtitle = landmark.context_description
                tourAnnotation.coordinate = location
                
                var title = landmark.title.componentsSeparatedByString(".")
                if let iconIndex = Int(title[0]) {
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
