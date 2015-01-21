//
//  ManagedObjectContext.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/20/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ManagedObjectContext {
    // define a global NSManagedObjectContext
    class var context: NSManagedObjectContext {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }

}