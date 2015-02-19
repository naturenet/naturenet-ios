//
//  ManagedAccount.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/15/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData

@objc(Account)
class Account: NNModel {

    @NSManaged var email: String
    @NSManaged var name: String
    @NSManaged var password: String
    @NSManaged var username: String
    let nsManagedContext: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext

    // pull info from remote server
    class func doPullByNameFromServer(parseService: APIService, name: String) {
        var accountUrl = APIAdapter.api.getAccountLink(name)
        parseService.getResponse(NSStringFromClass(Account), url: accountUrl)
    }
    
    func parseUserJSON(data: NSDictionary) -> Account {
        self.uid = data["id"] as Int
        self.username = data["username"] as String
        self.name = data["name"] as String
        self.password = data["password"] as String
        self.email = data["email"] as String
//        var createAt = UInt64(data["created_at"] as NSTimeInterval)
//        self.created_at = NSNumber(unsignedLongLong: createAt)
//        var modifiedAt = UInt64(data["modified_at"] as NSTimeInterval)
//        self.modified_at = NSNumber(unsignedLongLong: modifiedAt)
        self.created_at = data["created_at"] as NSNumber
        self.modified_at = data["modified_at"] as NSNumber
        return self
    }
    
    // update data in core data
    func doUpdateCoreData(pass: String, email: String, modified_at: NSNumber) {
        self.setValue(pass, forKey: "password")
        self.setValue(email, forKey: "email")
        self.setValue(modified_at, forKey: "modified_at")
        nsManagedContext.save(nil)
    }
    
    // push a new user to remote server as HTTP post
    // returned JSON will be sent to apiService's delegate: ObservationsController
    override func doPushNew(apiService: APIService) -> Void {
        var url = APIAdapter.api.getCreateAccountLink(self.username)
        var params = ["name": self.name, "password": self.password, "email": self.email] as Dictionary<String, Any>
        apiService.post(NSStringFromClass(Account), params: params, url: url)
    }
    
    func getNotes() -> [Note] {
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        var predicate = NSPredicate(format: "account = %@", self.objectID)
        var results = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Note), withPredicate: predicate, managedObjectContext: context) as [Note]
        return results
    }
    
    // update state 
    override func doUpdataState() {
        // println("after update, state is changed to: \(state)")
        self.setValue(state, forKey: "state")
        nsManagedContext.save(nil)
    }
    
    // toString, debug use
    func toString() -> String {
        var string = "username: \(username) pass: \(password) uid: \(uid)  modified: \(modified_at) username: \(username) state: \(state)"
        return string
    }
    
    // pull this user's note
    func pullnotes(parseService: APIService) {
        var accountUrl = APIAdapter.api.getAccountNotesLink(self.username)
        println("api service is from \(NSStringFromClass(Note)) url is: \(accountUrl) " )
        parseService.getResponse(NSStringFromClass(Note), url: accountUrl)
    }
    
}
