//
//  User.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/13/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation

class Account: APIControllerProtocol {
    var parseService: APIService = APIService()

    init() {
        parseService.delegate = self
    }
    
    func didReceiveResults(response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            println(response["data"])
            var data = response["data"] as NSDictionary!
            var id = data["id"] as Int
            var username = data["username"] as String
            var fullname = data["name"] as String
            var pass = data["password"] as String
            var email = data["email"] as String
            var created_at = data["created_at"] as Int
            ManagedAccount.createInManagedObjectContext(username, password: pass, name: fullname, created_at: created_at, uid: id, email: email)
        })
    }

    func doPullByName(name: String) {
        var apiLink = API()
        var accountUrl = apiLink.getAccountLink(name)
        parseService.getResponse(accountUrl)
    }

}