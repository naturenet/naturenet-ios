//
//  User.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/13/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Account: APIControllerProtocol {
    var parseService: APIService?
    var username: String?
    var password: String?
    var fullname: String?
    var createdAt: NSNumber?
    var uid: NSNumber?
    var email: String?
    
    var entityRef: AccountEntity?

    init() {
        parseService = APIService()
        parseService!.delegate = self
    }
    
    init(username: String, password: String, fullname: String, createdAt: NSNumber, uid: NSNumber, email: String) {
        self.username = username
        self.password = password
        self.fullname = fullname
        self.createdAt = createdAt
        self.uid = uid
        self.email = email
    }
    
    // after getting data from server
    func didReceiveResults(response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            println("data is loaded");
            var data = response["data"] as NSDictionary!
            var id = data["id"] as Int
            var username = data["username"] as String
            var fullname = data["name"] as String
            var pass = data["password"] as String
            var email = data["email"] as String
            var created_at = data["created_at"] as Int
            println("\(id) \(username) \(fullname) \(pass) \(created_at)")
            var account = Account(username: username, password: pass, fullname: fullname, createdAt: created_at, uid: id, email: email)
            var user = AccountEntity.createInManagedObjectContext(ManagedObjectContext.context, account: account)
            // assign a reference to the entity of this account
            self.entityRef = user
        })
    }

    func doPullByNameFromServer(name: String) {
        var accountUrl = APIAdapter.api.getAccountLink(name)
        if (parseService != nil) {
            parseService!.getResponse(accountUrl)
        }
    }
    
    func isValidUser(name: String, pass: String) -> Bool {
        
        return false
    }


}