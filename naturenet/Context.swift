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
