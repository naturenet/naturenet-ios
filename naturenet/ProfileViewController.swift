//
//  ProfileController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/2/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController, UITableViewDelegate, UINavigationControllerDelegate {
    
    // UI Outlets
    @IBOutlet var profileTableView: UITableView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var numOfObsLabel: UILabel!
    @IBOutlet weak var numOfDesignIdeasLabel: UILabel!
    
    
    var details = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupTableView()
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // returning to view
    override func viewWillAppear(animated: Bool) {
//        tblTasks.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // sign out is in section 2
        if indexPath.section == 2 {
            createPopAlert()
//            Session.signOut()
//            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    func createPopAlert() {
    
        var popover:UIPopoverController?
        var title = "Before you sign out, would you like to submit a design suggestion to make NatureNet better?"
        var alert:UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var cameraAction = UIAlertAction(title: "No (sign me out)", style: UIAlertActionStyle.Destructive) {
            UIAlertAction in
            Session.signOut()
            self.navigationController?.popToRootViewControllerAnimated(true)

        }
        
        var gallaryAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
            UIAlertAction in
        }
 
        // Add the actions
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        
        // Present the actionsheet
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else {
            popover = UIPopoverController(contentViewController: alert)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController!) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        println("picker cancel.")
    }

    
    private func setupTableView() {
        if let account = Session.getAccount() {
            var notes = account.getNotes()
            var numOfDesginIdeas = 0
            var numOfObservations = 0
            
            for note in notes {
                if note.kind == "FieldNote" {
                    numOfObservations++
                }
                if note.kind == "DesignIdea" {
                    numOfDesginIdeas++
                }
            }
            
            self.welcomeLabel.text = "Welcome, \(account.username)!"
            self.numOfObsLabel.text = String(numOfObservations)
            self.numOfDesignIdeasLabel.text = String(numOfDesginIdeas)
        }
    }
}
