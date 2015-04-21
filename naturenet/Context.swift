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
        self.uid = context["id"] as! Int
        self.name = context["name"] as! String
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
  
        self.title = context["title"] as! String
        self.kind = context["kind"] as! String
        self.state = STATE.DOWNLOADED
        return self
    }
    
    
    // update data in core data
    override func updateToCoreData(data: NSDictionary) {
        let managedContext: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        self.setValue(data["id"] as! Int, forKey: "uid")
        self.setValue(data["name"] as! String, forKey: "name")
        if let desc = data["description"] as? String {
            self.setValue(desc, forKey: "context_description")
        } else {
            self.setValue("", forKey: "context_description")
        }
        
        if let extras = data["extras"] as? String {
            self.setValue(extras, forKey: "extras")
        } else {
            self.setValue("", forKey: "extras")
        }
        
        self.setValue(data["title"] as! String, forKey: "title")
        self.setValue(data["kind"] as! String, forKey: "kind")
        self.state = STATE.DOWNLOADED
        self.setValue(STATE.DOWNLOADED, forKey: "state")
        SwiftCoreDataHelper.saveManagedObjectContext(managedContext)
    }
    
    // if context is the landmark, get the its cooridnate pair from extras
    func getCoordinatesForLandmark() -> CLLocation? {
        var location: CLLocation?
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
//            location = CLLocationCoordinate2DMake(latNumber, lonNumber)
            location = CLLocation(latitude: latNumber, longitude: lonNumber)
        }
        
        return location
    }

    class func getLandmarkByName(name: String, landmarks: [Context]) -> Context {
        var rLandmark: Context!
        for landmark in landmarks {
            if landmark.title == name {
                rLandmark = landmark
                break
            }
        }
        return rLandmark
    }
    
    // find context (e.g. landmark or activity)
    class func getContextByName(name: String, contexts: [Context]) -> Context! {
        var context: Context!
        for contx in contexts {
            if contx.title == name {
                context = contx
                break
            }
        }
        return context
    }
    
    func toString() -> String {
        return  "name: \(name) title: \(title)"
    }
}
