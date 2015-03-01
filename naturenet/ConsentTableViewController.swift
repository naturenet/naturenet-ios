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
    let firstConsent = "(Required) I agree to allow any comments, observations, and profile information" +
                        "that I choose to share with others via the online application to be visible to others who use the application at the same time or after me."
    var data: [String]?

    // To participate in NatureNet we will need you to agree to a few things:
    @IBOutlet var consentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.data = [firstConsent, firstConsent, firstConsent, firstConsent]
        let cellNib = UINib(nibName: "ConsentTableViewCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(cellNib, forCellReuseIdentifier: "consentTableViewCell")
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
        let cell = tableView.dequeueReusableCellWithIdentifier("consentTableViewCell", forIndexPath: indexPath) as ConsentTableViewCell
        cell.consentTextLabel?.text = data![indexPath.row]
        return cell
    }

//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0))
//        if selections[indexPath.row] == 0 {
//            cell?.accessoryType = .Checkmark
//            selections[indexPath.row] = 1
//        }
//
//    }
//    
//    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row, inSection: 0))
//        if selections[indexPath.row] == 1 {
//            cell?.accessoryType = .None
//            selections[indexPath.row] = 0
//        }
//    }
//
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "consentToSignUp" {
//            let destinationVC = segue.destinationViewController as SignUpViewController
//            var consentStr = ""
//            var selectedIndex = 0
//            for selection in selections {
//                if selection == 1 {
//                    let cell = consentTableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0))!
//                    consentStr += cell.textLabel!.text!
//                }
//                selectedIndex++
//            }
//            destinationVC.consentString = consentStr
//        }
//        
//    }
    
    @IBAction func consentSendPressed(sender: UIBarButtonItem) {
        if selections[0] == 0 || selections[1] == 0 {
            createWarningAlert()
        } else {
            self.performSegueWithIdentifier("consentToSignUp", sender: self)
        }
    }
    
    func createWarningAlert() {
        var alert = UIAlertController(title: "Opps", message: "You must agree required ones!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
