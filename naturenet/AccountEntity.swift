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
    @NSManaged var uid: NSNumber
    @NSManaged var username: String

    
    // save a new account in coredata
    class func createInManagedObjectContext(username: String, password: String,
        name: String, created_at: Int, uid: Int, email: String) -> AccountEntity {
            let context: NSManagedObjectContext = ManagedObjectContext.context
            let ent = NSEntityDescription.entityForName("Account", inManagedObjectContext: context)!
            let newAccount = AccountEntity(entity: ent, insertIntoManagedObjectContext: context)
            newAccount.username = username
            newAccount.password = password
            newAccount.name = name
            newAccount.created_at = created_at
            newAccount.uid = uid
            newAccount.email = email
            newAccount.state = State.NEW
            context.save(nil)
            println("newAccount is : \(newAccount)")
            return newAccount
    }

    
    // save a new account in coredata
    class func createInManagedObjectContext(context: NSManagedObjectContext, account: Account) -> AccountEntity {
            let ent = NSEntityDescription.entityForName("Account", inManagedObjectContext: context)!
            let newAccount = AccountEntity(entity: ent, insertIntoManagedObjectContext: context)
            newAccount.username = account.username!
            newAccount.password = account.password!
            newAccount.name = account.fullname!
            newAccount.created_at = account.createdAt!
            newAccount.uid = account.uid!
            newAccount.email = account.email!
            newAccount.state = State.NEW
            context.save(nil)
            println("newAccount is : \(newAccount)")
            return newAccount
    }

    // pull info from remote server
    class func doPullByNameFromServer(parseService: APIService, name: String) {
        var accountUrl = APIAdapter.api.getAccountLink(name)
        parseService.getResponse(accountUrl)
    }
    
    // pull information from coredata
    class func doPullByNameFromCoreData(name: String) -> Void {
        let context: NSManagedObjectContext = ManagedObjectContext.context
        let request = NSFetchRequest(entityName: "Account")
        request.returnsDistinctResults = false
        request.predicate = NSPredicate(format: "username = %@", name)
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        // println(results)
        if results.count > 0 {
            for user in results {
                if let tUser = user as? AccountEntity {
                    println(tUser.toString())
                }
            }
        } else {
            println("no user matched")
        }
    }
    
    // create an instance of Account from AccountEntity
    func createInstanceFromEntity(entity: AccountEntity) -> Account {
        var account = Account(username: entity.username, password: entity.password, fullname: entity.name,
                createdAt: entity.created_at, uid: entity.uid, email: entity.email)
        account.entityRef = entity
        return account
    }
    
    // toString, debug use
    func toString() -> String {
        var string = "name: \(name)" + " pass: \(password)" + " uid: \(uid)" + " username: \(username)"
        return string
    }
    
}
