//
//  ProfileController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/2/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController, UITableViewDelegate, UINavigationControllerDelegate, saveInputStateProtocol {
    
    // UI Outlets
    @IBOutlet var profileTableView: UITableView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var numOfObsLabel: UILabel!
    @IBOutlet weak var numOfDesignIdeasLabel: UILabel!
    
    // for saving design idea input from design idea controller
    var designIdeaInput: String?
    
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
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // sign out is in section 2
        if indexPath.section == 3 {
            createPopAlert()
        }
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                self.performSegueWithIdentifier("profileToDesignIdea", sender: self)
            }
        }
    }
    
    @IBAction func backpressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "profileToDesignIdea" {
            let destinationVC = segue.destinationViewController as! DesignIdeaViewController
            destinationVC.delegate = self
            if self.designIdeaInput != nil {
                destinationVC.designIdeaSavedInput = self.designIdeaInput
            }
        }
    }
    
    // implement saveInputStateProtocol
    func saveInputState(input: String?) {
        self.designIdeaInput = input
    }
    
    func createPopAlert() {
        var popover:UIPopoverController?
        var title = "Before you sign out, do you have any suggestions to make NatureNet better?"
        var alert:UIAlertController = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        var singoutAction = UIAlertAction(title: "Sign me out", style: UIAlertActionStyle.Destructive) {
            UIAlertAction in
            Session.signOut()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        
        var yesAction = UIAlertAction(title: "Leave a design idea", style: UIAlertActionStyle.Default) {
            UIAlertAction in
            self.performSegueWithIdentifier("profileToDesignIdea", sender: self)

        }
        
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
 
        // Add the actions
        alert.addAction(singoutAction)
        alert.addAction(yesAction)
        alert.addAction(cancelAction)
        
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
        // println("picker cancel.")
    }
    
    private func setupTableView() {
        if let account = Session.getAccount() {
            var notes = account.getNotes()
            var numOfDesginIdeas = 0
            var numOfObservations = 0
            
            for note in notes {
                // only counts synced notes
                if note.state == NNModel.STATE.SYNCED {
                    if note.kind == "FieldNote" {
                        numOfObservations++
                    }
                    if note.kind == "DesignIdea" {
                        numOfDesginIdeas++
                    }
                }
            }
            
            self.welcomeLabel.text = "Welcome, \(account.username)!"
            self.numOfObsLabel.text = String(numOfObservations)
            self.numOfDesignIdeasLabel.text = String(numOfDesginIdeas)
        }
    }
}
