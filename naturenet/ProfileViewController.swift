//
//  ProfileController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/2/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController, UITableViewDelegate {
    
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
            Session.signOut()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
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
