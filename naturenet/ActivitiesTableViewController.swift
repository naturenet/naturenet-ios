//
//  ActivitiesTableViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/12/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ActivitiesTableViewController: UITableViewController {

    var activities: [Context] = [Context]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if Session.isSignedIn() {
            if let site: Site = Session.getSite() {
                let siteContexts = site.getContexts()
                for sContext in siteContexts {
                    let context = sContext as! Context
                    if context.kind == "Activity" {
                        self.activities.append(context)
                    }
                }
            }
        }

         // Uncomment the following line to preserve selection between presentations
         self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.refreshControl = UIRefreshControl()
//        self.refreshControl?.backgroundColor = UIColor.purpleColor()
        self.refreshControl?.tintColor = UIColor.darkGrayColor()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: "refreshActivityList", forControlEvents: UIControlEvents.ValueChanged)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data sourc
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var rows: Int!
        if section == 0 {
            rows = activities.count
        }
        if section == 1 {
            rows = 1
        }
        
        return rows
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerTitle: String!
        if section == 0 {
            headerTitle = "Activities in ACES"
        }
        if section == 1 {
            headerTitle = "Activities out of ACES"
        }
        return headerTitle
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activitiesCell", forIndexPath: indexPath) as! UITableViewCell
        if indexPath.section == 0 {
            var activity = self.activities[indexPath.row] as Context
            cell.textLabel?.text = activity.title
            var activityIconURL = activity.extras
            loadImageFromWeb(activityIconURL, cell: cell, index: indexPath.row)
        }
        
        if indexPath.section == 1 {
            cell.textLabel?.text = "Not in Aspen"
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.performSegueWithIdentifier("activityDetail", sender: indexPath)
        }
        if indexPath.section == 1 {
            self.performSegueWithIdentifier("birdCounting", sender: indexPath)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "activityDetail" {
            let destinationVC = segue.destinationViewController as! ActivityDetailViewController
            // if passed from a cell
            if let indexPath = sender as? NSIndexPath {
                let selectedCell = activities[indexPath.row]
                destinationVC.activity = selectedCell
            }
        }
        
        if segue.identifier == "birdCounting" {
            
        }

    }
    
    private func loadImageFromWeb(iconURL: String, cell: UITableViewCell, index: Int ) {
        var url = NSURL(string: iconURL)
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
            } else {
                let image = UIImage(data: data)
                cell.imageView?.image = image
            }
        })
    }
    
    func refreshActivityList() {
//        self.refreshControl?.attributedTitle = NSString("Last Upate: ")
        self.refreshControl?.endRefreshing()
    }

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
