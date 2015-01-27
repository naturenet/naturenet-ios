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
    var parseService = APIService()

    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTap(sender: UIControl) {
        textFieldUname.resignFirstResponder()
        textFieldUpass.resignFirstResponder()
    }
    
    @IBAction func btnSignIn() {
        textFieldUname.resignFirstResponder()
        textFieldUpass.resignFirstResponder()
        parseService.delegate = self
        let inputUser = textFieldUname.text
        createIndicator()
        Account.doPullByNameFromServer(parseService, name: inputUser)
    }
    
    // after getting data from server
    func didReceiveResults(from: String, response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as Int
            if (status == 400) {
                var errorMessage = "User Doesn't Exisit"
                self.createAlert(errorMessage)
                self.pauseIndicator()
                return
            }
            
            println("received results from \(from)")

            if from == "Account" {
                // var data = response["data"] as NSDictionary!
                var data = response["data"] as NSDictionary!
                var model = data["_model_"] as String
                self.handleUserData(data)
            }
            
            if from == "Site" {
                var data = response["data"] as NSDictionary!
                var model = data["_model_"] as String
                // var data = response["data"] as NSDictionary!
                self.handleSiteData(data)
            }
            
            if from == "Note" {
                var data = response["data"] as NSArray!
                // println("notes are: \(data)")
                self.handleNoteData(data)
            }
        })
    }
    
    // parse account info and save
    func handleUserData(data: NSDictionary) {
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
        
        var existingAccount = Account.doPullByNameFromCoreData(username)?
        if existingAccount != nil {
            println("input user existing in core date: \(existingAccount?.toString())")
            // println("You have this user in core data: \(inputUser)")
            var existingPass = existingAccount!.password
            var existingModifiedAt = existingAccount!.modified_at
            if existingModifiedAt != modified_at {
                // usually user only is alllowed to change pass, email
                existingAccount!.doUpdateCoreData(pass, email: email, modified_at: modified_at)
                existingAccount!.commit()
            }
            existingAccount!.pullnotes(parseService)
        } else {
            // println("You don't have this user in core data: \(username)")
            var user = Account.createInManagedObjectContext(username, password: pass, name: fullname,
                created_at: created_at, modified_at: modified_at, uid: id, email: email)
            user.commit()
            user.pullnotes(parseService)
        }
        
        Site.doPullByNameFromServer(parseService, name: "aces")
    }
    
    // parse site info and save
    func handleSiteData(data: NSDictionary) {
        // println("site is : \(data)")
        var contexts = data["contexts"] as NSArray
        // println("site contexts is : \(contexts[1])")
        var description = data["description"] as String
        var uid = data["id"] as Int
        var image_url = data["image_url"] as String
        var name = data["name"] as String
        // let site_contexts: [[String: AnyObject?]] = self.convertContextData(contexts)
        var exisitingSite = Site.doPullByNameFromCoreData("aces")?
        if exisitingSite != nil {
            println("You have aces site in core data: "  + exisitingSite!.toString())
        } else {
            var site = Site.createInManagedObjectContext(name, uid: uid, description: description, imageURL: image_url)
            self.handleContextData(site, contexts: contexts)
            site.commit()
            println("A new site " + site.toString() + " saved")
        }
        
         self.pauseIndicator()
         self.navigationController?.popToRootViewControllerAnimated(true)

    }
    
    // save context
    func handleContextData(site: Site, contexts: NSArray) {
        if (contexts.count == 0) {
            return
        }
        
        for tContext in contexts {
            var contextUID = tContext["id"] as Int
            var name = tContext["name"] as String
            var cDescription: String?
            if tContext["description"] != nil {
                cDescription = tContext["description"] as? String
            }
            
            var extras: String?
            if var ext = tContext["extras"] as? String {
                extras = ext as String
            }
            var title = tContext["title"] as String
            var kind = tContext["kind"] as String
            var context = Context.createInManagedObjectContext(name, description: cDescription, uid: contextUID,
                            site: site, kind: kind, title: title, extras: extras)
            context.commit()
            println("A new context:{ " + context.toString() + " } saved!")
        }
    }
    
    // save notes
    func handleNoteData(notes: NSArray) {
        // println("notes are: \(notes)")
        if (notes.count == 0) {
            return
        }
        
        for mNote in notes {
            let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
            var note =  SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: context) as Note
            note.parseNoteJSON(mNote as NSDictionary)
            println("note with \(note.uid) is: { \(note.toString()) }")
            SwiftCoreDataHelper.saveManagedObjectContext(context)
        }
    }
    
    // parse contexts json to an array contains a list of dictionary
    func convertContextData(contexts: NSArray) -> [[String: AnyObject?]]  {
        var contextDictArrays: [[String: AnyObject?]] = []
        if (contexts.count == 0) {
            return contextDictArrays
        }
        
        for tContext in contexts {
            var contextUID = tContext["id"] as Int
            var name = tContext["name"] as String
            var cDescription: String?
            if tContext["description"] != nil {
                cDescription = tContext["description"] as? String
            }
            
            var extras: String?
            if var ext = tContext["extras"] as? String {
                extras = ext as String
            }
            var title = tContext["title"] as String
            var kind = tContext["kind"] as String
            var contextDict: [String: AnyObject?]  = ["uid": contextUID, "description": cDescription, "title": title, "kind": kind, "extras": extras]
            contextDictArrays.append(contextDict)
        }
        
        // println(contextDictArrays)
        return contextDictArrays
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
