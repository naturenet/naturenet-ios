//
//  Context.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/26/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData

@objc(Context)
class Context: NNModel {

    @NSManaged var context_description: String
    @NSManaged var extras: String
    @NSManaged var kind: String
    @NSManaged var name: String
    @NSManaged var title: String
    @NSManaged var site_uid: NSNumber
    @NSManaged var site: Site
    
    // save a new account in coredata
    class func createInManagedObjectContext(name: String, description: String?, uid: Int, site: Site, kind: String, title: String, extras: String?) -> Context {
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let ent = NSEntityDescription.entityForName("Context", inManagedObjectContext: context)!
        let newContext = Context(entity: ent, insertIntoManagedObjectContext: context)
        // newContext.created_at = NSDate().timeIntervalSince1970
        if description != nil {
            newContext.context_description = description!
        }
        newContext.kind = kind
        newContext.name = name
        newContext.uid = uid
        newContext.site_uid = site.uid
        newContext.title = title
        newContext.site = site
        if extras != nil {
            newContext.extras = extras!
        }
        newContext.state = STATE.DOWNLOADED
        context.save(nil)
        // println("newContext is : \(newContext)" + "Account entity is: " + newContext.toString())
        return newContext
    }
    
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

    func toString() -> String {
        return  "name: \(name) title: \(title)"
    }
}
