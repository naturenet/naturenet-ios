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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initMap() {
    // 39.195998, -106.821823
        var latitude: CLLocationDegrees = 39.195998
        var longitude: CLLocationDegrees = -106.821823
        var latDelta: CLLocationDegrees = 0.01
        var lonDelta: CLLocationDegrees = 0.01
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        var region: MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        
        acesMapView.setRegion(region, animated: true)
        acesMapView.mapType = MKMapType.Satellite
    }
    
    func setAnnotation(location: CLLocationCoordinate2D) {
        var annotation = MKPointAnnotation()
        annotation.coordinate = location
    }
    
    // given latitude and longtitude, return CLLocationCoordinate2D
    func coordinatesToLocation(latitude: CLLocationDegrees, longitude: CLLocationDegrees,
                    latDelta: CLLocationDegrees, lonDelta: CLLocationDegrees) -> CLLocationCoordinate2D {
        var span: MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        var location: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        return location
    }
    
    func loadLocations() {
        if let site = Session.getSite() {
            
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
