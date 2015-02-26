//
//  Context.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/26/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData
import MapKit

@objc(Context)
class Context: NNModel {

    @NSManaged var context_description: String
    @NSManaged var extras: String
    @NSManaged var kind: String
    @NSManaged var name: String
    @NSManaged var title: String
    @NSManaged var site_uid: NSNumber
    @NSManaged var site: Site
    
    func parseContextJSON(context: NSDictionary) -> Context {
        self.uid = context["id"] as Int
        self.name = context["name"] as String
        if let desc = context["description"] as? String {
            self.context_description = desc
        } else {
            self.context_description = ""
        }
        
        if let extras = context["extras"] as? String {
            self.extras = extras
        } else {
            self.extras = ""
        }
  
        self.title = context["title"] as String
        self.kind = context["kind"] as String
        self.state = STATE.DOWNLOADED
        return self
    }
    
    // if context is the landmark, get the its cooridnate pair from extras
    func getCoordinatesForLandmark() -> CLLocationCoordinate2D? {
        var location: CLLocationCoordinate2D?
        if self.kind != "Landmark" {
            return nil
        }
        
        var extras = self.extras
        // because entry "Other" has no extras, no description
        if !extras.isEmpty {
            var coordinate = extras.componentsSeparatedByString(",") as [String]
            var latCoordinate = coordinate[0].componentsSeparatedByString(":") as [String]
            var lonCoordinate = coordinate[1].componentsSeparatedByString(":") as [String]
            var latNumber = (latCoordinate[1] as NSString).doubleValue
            var lonNumber = (lonCoordinate[1] as NSString).doubleValue
            location = CLLocationCoordinate2DMake(latNumber, lonNumber)
        }
        
        return location
    }

    func toString() -> String {
        return  "name: \(name) title: \(title)"
    }
}
