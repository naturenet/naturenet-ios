//
//  Session.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/25/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData

@objc(Session)
class Session: NSManagedObject {

    @NSManaged var account_id: NSNumber
    @NSManaged var site_id: NSNumber
    @NSManaged var account: Account
    @NSManaged var context: Context
    
    class var sharedInstance: Session {
        struct Singleton {
            static let instance = Session()
        }
        return Singleton.instance
    }
    
    class func isSignedIn() -> Bool {
        var isSigned: Bool = false;
        
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let request = NSFetchRequest(entityName: "Session")
        request.returnsDistinctResults = false
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        println("session retrieved \(results)")
        if results.count > 0 {
            for session in results {
                if session.account_id.integerValue > 0 {
                    isSigned = true
                }
            }
        }
        
        return isSigned
    }
    
    class func signIn(accountID: Int, siteID: Int) {
        let managedContext: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        var session = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Session), managedObjectConect: managedContext) as Session
        session.account_id = accountID
        session.site_id = siteID
        SwiftCoreDataHelper.saveManagedObjectContext(managedContext)
    }
    
    class func signIn(account: Account, context: Context) {
        let managedContext: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        var session = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Session), managedObjectConect: managedContext) as Session
        session.account = account
        session.context = context
        SwiftCoreDataHelper.saveManagedObjectContext(managedContext)
    }
    
    class func signOut() {
        
    }
    
  
}
