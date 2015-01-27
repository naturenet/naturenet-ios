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
    
    class func isSignedIn() -> Bool {
        var isSigned: Bool = false;
        
        let context: NSManagedObjectContext = ManagedObjectContext.context
        let request = NSFetchRequest(entityName: "Session")
        request.returnsDistinctResults = false
//        request.predicate = NSPredicate(format: "account_id = %@", name)
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
    
    class func signIn(account: AccountEntity) {
        let context: NSManagedObjectContext = ManagedObjectContext.context
        let ent = NSEntityDescription.entityForName("Session", inManagedObjectContext: context)!
        var session = Session(entity: ent, insertIntoManagedObjectContext: context)
        session.account_id = account.uid
        context.save(nil)
    }
}
