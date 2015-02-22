//
//  SignIn.swift
//  NatureNet
//
//  Created by Jinyue Xia on 1/1/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreData

class SignInViewController: UIViewController, APIControllerProtocol {
    var signInIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var site: Site?
    var account: Account?

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
        createIndicator()
        Site.doPullByNameFromServer(parseService, name: "aces")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            
            // println("received results from \(from)")
            if from == "Account" {
                // var data = response["data"] as NSDictionary!
                var data = response["data"] as NSDictionary!
                var model = data["_model_"] as String
                self.handleUserData(data)
            }
            
            if from == "Site" {
                var data = response["data"] as NSDictionary!
                var model = data["_model_"] as String
                self.handleSiteData(data)
            }
            
            if from == "Note" {
                // response["data"] is an array of notes
                var data = response["data"] as NSArray!
                self.handleNoteData(data)
                self.pauseIndicator()
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        })
    }
    
    // parse account info and save
    func handleUserData(data: NSDictionary) {
        var username = data["username"] as String
        var pass = data["password"] as String
        var email = data["email"] as String
        var modified_at = data["modified_at"] as NSNumber
        
        if pass != self.textFieldUpass.text {
            var errorMessage = "Password is Wrong"
            self.createAlert(errorMessage)
            self.pauseIndicator()
            return
        }
                
        var existingAccount = NNModel.doPullByNameFromCoreData(NSStringFromClass(Account), attr: "username", name: username) as Account?
        if existingAccount != nil {
            // println("input user existing in core date: \(existingAccount?.toString())")
            // println("You have this user in core data: \(inputUser)")
            var existingModifiedAt = existingAccount!.modified_at
            if existingModifiedAt != modified_at {
                // usually user only is alllowed to change pass, email
                existingAccount!.doUpdateCoreData(pass, email: email, modified_at: modified_at)
                existingAccount!.commit()
            }
            self.account = existingAccount
        } else {
            // println("You don't have this user in core data: \(username)")
            self.account = Account.saveToCoreData(data)
        }
        Session.signIn(self.account!, site: self.site!)
        self.account!.pullnotes(parseService)
    }
    
    // parse site info and save
    // !!!if site exists, no update, should check modified date is changed!! but no modified date returned from API
    func handleSiteData(data: NSDictionary) {
        var sitename = data["name"] as String
        var exisitingSite = NNModel.doPullByNameFromCoreData(NSStringFromClass(Site), attr:"name", name: "aces") as? Site
        if exisitingSite != nil {
            // println("You have aces site in core data: "  + exisitingSite!.toString())
            // should check if modified date is changed here!! but no modified date returned from API
            self.site = exisitingSite
        } else {
            self.site = Site.saveToCoreData(data)
        }
        let inputUser = textFieldUname.text
        Account.doPullByNameFromServer(parseService, name: inputUser)
    }
    
       
    // save notes
    func handleNoteData(notes: NSArray) {
        // println("notes are: \(notes)")
        if (notes.count == 0) {
            return
        }
        
        for mNote in notes {
            var serverNote = mNote as NSDictionary
            var localNote: Note?
            let noteUID = serverNote["id"] as Int
            let predicate = NSPredicate(format: "uid = \(noteUID)")
            let nsManagedContext: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
            let items = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Note), withPredicate: predicate, managedObjectContext: nsManagedContext) as [Note]

            if (items.count > 0) {
                localNote = items[0]
            }
            
            if localNote != nil {
                if localNote!.modified_at != serverNote["modified_at"] as NSNumber {
                    localNote!.updateNote(serverNote)
                }
            } else {
                // save mNote as a new note entry
                Note.saveToCoreData(mNote as NSDictionary)
            }
        }
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
