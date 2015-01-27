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
    @NSManaged var site_id: NSNumber
    @NSManaged var title: String
    @NSManaged var site: Site
    
    // save a new account in coredata
    class func createInManagedObjectContext(name: String, description: String?, uid: Int, siteID: Int, kind: String, title: String, extras: String?) -> Context {
        let context: NSManagedObjectContext = ManagedObjectContext.context
        let ent = NSEntityDescription.entityForName("Context", inManagedObjectContext: context)!
        let newContext = Context(entity: ent, insertIntoManagedObjectContext: context)
        // newContext.created_at = NSDate().timeIntervalSince1970
        if description != nil {
            newContext.context_description = description!
        }
        newContext.kind = kind
        newContext.name = name
        newContext.uid = uid
        newContext.site_id = siteID
        newContext.title = title
        if extras != nil {
            newContext.extras = extras!
        }
        newContext.state = STATE.DOWNLOADED
        context.save(nil)
        // println("newContext is : \(newContext)" + "Account entity is: " + newContext.toString())
        return newContext
    }

    func toString() -> String {
        return "name: \(name) description: \(context_description) title: \(title)"
    }
    
}
