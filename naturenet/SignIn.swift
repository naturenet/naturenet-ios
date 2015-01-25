//
//  SignIn.swift
//  nn
//
//  Created by Jinyue Xia on 1/1/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreData

class SignIn: UIViewController, APIControllerProtocol {
    @IBOutlet weak var textFieldUname: UITextField!
    @IBOutlet weak var textFieldUpass: UITextField!
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTap(sender: UIControl) {
        textFieldUname.resignFirstResponder()
        textFieldUpass.resignFirstResponder()
    }
    
    @IBAction func btnSignIn() {
        var parseService = APIService()
        parseService.delegate = self
//        AccountEntity.doPullByNameFromServer(parseService, name: "car")
        AccountEntity.doPullByNameFromCoreData("car")
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
            // var account = Account(username: username, password: pass, fullname: fullname, createdAt: created_at, uid: id, email: email)
            // var user = AccountEntity.createInManagedObjectContext(ManagedObjectContext.context, account: account)
            var user = AccountEntity.createInManagedObjectContext(username, password: pass, name: fullname, created_at: created_at, uid: id, email: email)
        })
    }

    
}
