//
//  ConsentTableViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/18/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ConsentTableViewController: UITableViewController {
    
    var selections:[Int] = [0, 0, 0, 0]
    let firstConsent = "(Required) I agree that any nature photos I take using the NatureNet application" +
                            " may be uploaded to the tabletop at ACES and/or a website now under development."
    let secondConsent = "(Required) I agree to allow any comments, observations, and profile information" +
                        " that I choose to share with others via the online application to be visible to " +
                        "others who use the application at the same time or after me."
    let thirdConsent = "(Optional) I agree to be videotaped/audiotaped during my participation in this study."
    let forthConsent = "(Optional) I agree to complete a short questionnaire during or after my participation in this study."
    var data: [String]?

    let consentTitle = "To participate in NatureNet we will need you to agree to a few things:"
    @IBOutlet var consentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.data = [firstConsent, secondConsent, thirdConsent, forthConsent]
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data!.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellNib = UINib(nibName: "ConsentTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "consentTableViewCell")
        let cell = tableView.dequeueReusableCellWithIdentifier("consentTableViewCell", forIndexPath: indexPath) as! ConsentTableViewCell
        cell.consentTextLabel?.text = data![indexPath.row]
    
        return cell
    }
 
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.consentTitle
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! ConsentTableViewCell
        cell.setSelected(true, animated: true)
        if !cell.consentSwitch.on {
            cell.consentSwitch.on = true
        } else {
            cell.consentSwitch.on = false
        }

    }
  
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0)) as! ConsentTableViewCell
            cell.consentSwitch.on = false
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "consentToSignUp" {
            let destinationVC = segue.destinationViewController as! SignUpViewController
            var consentStr = ""
            var selectedIndex = 0
            for selection in selections {
                if selection == 1 {
                    let cell = consentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0))! as! ConsentTableViewCell
                    consentStr += cell.consentTextLabel!.text!
                }
                selectedIndex++
            }
            
            destinationVC.consentString = consentStr
        }
        
    }
    
    @IBAction func consentSendPressed(sender: UIBarButtonItem) {
        for index in 0...3 {
            let cell = consentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0))! as! ConsentTableViewCell
            if cell.selected {
                selections[index] = 1
            } else {
                selections[index] = 0
            }
        }
        if selections[0] == 0 || selections[1] == 0 {
            createWarningAlert()
        } else {
            self.performSegueWithIdentifier("consentToSignUp", sender: self)
        }
    }
    
    func createWarningAlert() {
        var alert = UIAlertController(title: "Oops", message: "You must agree required ones!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
}
