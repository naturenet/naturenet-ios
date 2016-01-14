//
//  SwiftCoreDataHelper.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/27/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SwiftCoreDataHelper {
    class var nsManagedObjectContext: NSManagedObjectContext {
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.managedObjectContext!
        return context
    }
    
    class func insertManagedObject(className: String, managedObjectConect:NSManagedObjectContext) -> AnyObject {
        let managedObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: managedObjectConect) 
        
        return managedObject
        
    }
    
    class func getEntityByModelName(className:NSString, managedObjectContext:NSManagedObjectContext) -> AnyObject {
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        let entetyDescription:NSEntityDescription = NSEntityDescription.entityForName(className as String, inManagedObjectContext: managedObjectContext)!
        let entity = NSManagedObject(entity: entetyDescription, insertIntoManagedObjectContext: managedObjectContext)
        return entity
    }
    
    
    class func saveManagedObjectContext (managedObjectContext:NSManagedObjectContext) -> Bool {
        do {
            try managedObjectContext.save()
            return true
        } catch _ {
            return false
        }
    }
    
    class func fetchEntities(className: String, withPredicate predicate:NSPredicate?, managedObjectContext:NSManagedObjectContext) -> NSArray{
        let fetchRequest:NSFetchRequest = NSFetchRequest()
        let entetyDescription:NSEntityDescription = NSEntityDescription.entityForName(className, inManagedObjectContext: managedObjectContext)!
        
        fetchRequest.entity = entetyDescription
        if predicate != nil {
            fetchRequest.predicate = predicate!
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        let items:NSArray = try! managedObjectContext.executeFetchRequest(fetchRequest)
        
        return items
    }
    
    class func fetchEntitySingle(className: String, withPredicate predicate: NSPredicate?, managedObjectContext:NSManagedObjectContext) -> AnyObject? {
        var entity: AnyObject?
        let entities = fetchEntities(className, withPredicate: predicate, managedObjectContext:managedObjectContext)
        if entities.count > 0 {
            entity = entities[0] as AnyObject
        }
        
        return entity
    }
    

}