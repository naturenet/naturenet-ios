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
    var signInIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

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
        let inputUser = textFieldUname.text
        createIndicator()
        AccountEntity.doPullByNameFromServer(parseService, name: inputUser)
    }
    
    // after getting data from server
    func didReceiveResults(response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            println("data is loaded");
            var status = response["status_code"] as Int
            if (status == 400) {
                var errorMessage = "User Doesn't Exisit"
                self.createAlert(errorMessage)
                self.pauseIndicator()
                return 
            }
            
            var data = response["data"] as NSDictionary!
            var id = data["id"] as Int
            var username = data["username"] as String
            var fullname = data["name"] as String
            var pass = data["password"] as String
            var email = data["email"] as String
            var created_at = data["created_at"] as Int
            var modified_at = data["modified_at"] as Int
            
            if pass != self.textFieldUpass.text {
                var errorMessage = "Password is Wrong"
                self.createAlert(errorMessage)
                self.pauseIndicator()
                return
            }
            
            var existingAccount = AccountEntity.doPullByNameFromCoreData(username)?
            if existingAccount != nil {
                // println("You have this user in core data: \(inputUser)")
                var existingPass = existingAccount!.password
                var existingModifiedAt = existingAccount!.modified_at
                if existingModifiedAt != modified_at {
                    // usually user only is alllowed to change pass, email
                    existingAccount?.doUpdateCoreData(pass, email: email, modified_at: modified_at)
                }
            } else {
                // println("You don't have this user in core data: \(username)")
                var user = AccountEntity.createInManagedObjectContext(username, password: pass, name: fullname,
                    created_at: created_at, modified_at: modified_at, uid: id, email: email)
            }
            self.pauseIndicator()
            self.navigationController?.popToRootViewControllerAnimated(true)
        })
    }
    
    // create a loading indicator for sign in
    func createIndicator() {
        signInIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        signInIndicator.center = self.view.center
        signInIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(signInIndicator)
        signInIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    func pauseIndicator() {
        signInIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }
    
    // create an alert
    func createAlert(message: String) {
        var alert = UIAlertController(title: "Sign In Failed", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
