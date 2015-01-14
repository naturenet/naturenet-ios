//
//  Account.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/12/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class ManagedAccount: NNModel {
    
    @NSManaged var username: String
    @NSManaged var password: String
    @NSManaged var name: String
//    @NSManaged var created_at: NSNumber
    @NSManaged var uid: NSNumber
//    @NSManaged var state: NSNumber
    @NSManaged var email: String

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    // save a new account in coredata
    func createInManagedObjectContext(username: String, password: String,
        name: String, created_at: Int, uid: Int, email: String) -> ManagedAccount {
            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
            let ent = NSEntityDescription.entityForName("Account", inManagedObjectContext: context)!
            let newAccount = ManagedAccount(entity: ent, insertIntoManagedObjectContext: context)
            self.username = username
            newAccount.password = password
            newAccount.name = name
            newAccount.created_at = created_at
            newAccount.uid = uid
            newAccount.email = email
            newAccount.state = State.DOWNLOADED
            context.save(nil)
            println(newAccount)
            return newAccount
    }
    
}
