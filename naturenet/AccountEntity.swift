//
//  ManagedAccount.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/15/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData

@objc(AccountEntity)
class AccountEntity: NNModel {

    @NSManaged var email: String
    @NSManaged var name: String
    @NSManaged var password: String
    @NSManaged var username: String
    let context: NSManagedObjectContext = ManagedObjectContext.context


    // save a new account in coredata
    class func createInManagedObjectContext(username: String, password: String,
                name: String, created_at: Int, modified_at: Int, uid: Int, email: String) -> AccountEntity {
        let context: NSManagedObjectContext = ManagedObjectContext.context
        let ent = NSEntityDescription.entityForName("Account", inManagedObjectContext: context)!
        let newAccount = AccountEntity(entity: ent, insertIntoManagedObjectContext: context)
        newAccount.username = username
        newAccount.password = password
        newAccount.name = name
        newAccount.created_at = created_at
        newAccount.modified_at = modified_at
        newAccount.uid = uid
        newAccount.email = email
        newAccount.state = STATE.DOWNLOADED
        context.save(nil)
        println("newAccount is : \(newAccount)" + "Account entity is: " + newAccount.toString())
        return newAccount
    }

    // pull info from remote server
    class func doPullByNameFromServer(parseService: APIService, name: String) {
        var accountUrl = APIAdapter.api.getAccountLink(name)
        parseService.getResponse(accountUrl)
    }
    
    // update data in core data
    func doUpdateCoreData(pass: String, email: String, modified_at: Int) {
        self.setValue(pass, forKey: "password")
        self.setValue(email, forKey: "email")
        self.setValue(modified_at, forKey: "modified_at")
        context.save(nil)
    }
    
    // update state 
    override func doUpdataState() {
        println("after update, state is changed to: \(state)")
        self.setValue(state, forKey: "state")
        context.save(nil)
    }
    
    // pull information from coredata
    class func doPullByNameFromCoreData(name: String) -> AccountEntity? {
        var account: AccountEntity?
        let context: NSManagedObjectContext = ManagedObjectContext.context
        let request = NSFetchRequest(entityName: "Account")
        request.returnsDistinctResults = false
        request.predicate = NSPredicate(format: "username = %@", name)
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        if results.count > 0 {
            for user in results {
                if let tUser = user as? AccountEntity {
                    // println(tUser.toString())
                    account = tUser
                }
            }
        } else {
            println("no user matched")
        }
        return account
    }
    
    // toString, debug use
    func toString() -> String {
        var string = "username: \(username) pass: \(password) uid: \(uid)  modified: \(modified_at) username: \(username) state: \(state)"
        return string
    }
    
}
