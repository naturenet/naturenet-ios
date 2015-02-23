//
//  TourViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/22/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import MapKit

class TourViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var acesMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initMap()
        var locations = getLocations()
        for location in locations {
            if location.location != nil {
                setAnnotation(location)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMap() {
        var latitude: CLLocationDegrees = 39.195998
        var longitude: CLLocationDegrees = -106.821823
        var latDelta: CLLocationDegrees = 0.0001
        var lonDelta: CLLocationDegrees = 0.0001
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        acesMapView.setRegion(region, animated: true)
        acesMapView.mapType = MKMapType.Satellite
    }
    
    func setAnnotation(location: TourLocation) {
        var annotation = MKPointAnnotation()
        annotation.coordinate = location.location!
        annotation.title = location.title
        annotation.subtitle = location.locationDescription!
        
        self.acesMapView.addAnnotation(annotation)
    }
    
    // given latitude and longtitude, return CLLocationCoordinate2D
    func coordinatesToLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                    latDelta: CLLocationDegrees, lonDelta: CLLocationDegrees) -> CLLocationCoordinate2D {
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        return location
    }
    
    func getLocations() -> [TourLocation] {
        var latNumber: CLLocationDegrees?
        var lonNumber: CLLocationDegrees?
        var tourLocations = [TourLocation]()
        if let site = Session.getSite() {
            var landmarks = site.getLandmarks()
            for landmark in landmarks {
                var extras = landmark.extras
                var tourLocation = TourLocation()
                tourLocation.title = landmark.title
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
                tourLocation.locationDescription = landmark.context_description
                tourLocation.location = location
                tourLocations.append(tourLocation)
            }
        }
        return tourLocations
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    class TourLocation {
        var location: CLLocationCoordinate2D?
        var title: String!
        var locationDescription: String?
        
        init(){}
        
        init(location: CLLocationCoordinate2D, title: String, locationDescription: String) {
            self.location = location
            self.title = title
            self.locationDescription = locationDescription
        }
    }
}
