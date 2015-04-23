//
//  ActivitiesTableViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/12/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreData

class ActivitiesTableViewController: UITableViewController, APIControllerProtocol {

    var acesActivities: [Context] = [Context]()
    var nonAcesActivities: [Context] = [Context]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadActivities()
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

    // MARK: - Table view data source
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
            rows = acesActivities.count
        }
        if section == 1 {
            rows = nonAcesActivities.count
        }
        
        return rows
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerTitle: String!
        if section == 0 {
            headerTitle = "Activities in ACES"
        }
        if section == 1 {
            headerTitle = "Not in ACES"
        }
        return headerTitle
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activitiesCell", forIndexPath: indexPath) as! UITableViewCell
        var activityIconURL: String!

        if indexPath.section == 0 {
            var activity = self.acesActivities[indexPath.row] as Context
            cell.textLabel?.text = activity.title
//            if activity.name != "aces_Bird_Counting" {
//                activityIconURL = activity.extras
//            } else if activity.name == "aces_Bird_Counting" {
//                let birdsURLs = activity.extras as NSString
//                if let data = birdsURLs.dataUsingEncoding(NSUTF8StringEncoding)  {
//                    let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
//                    activityIconURL = json["Icon"] as! String
//                }
//            }
            
            
            let birdsURLs = activity.extras as NSString
            if let data = birdsURLs.dataUsingEncoding(NSUTF8StringEncoding)  {
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                    activityIconURL = json["Icon"] as! String
                } else {
                    activityIconURL = birdsURLs as String
                }
            } else {
                activityIconURL = birdsURLs as String
            }
        }
        
        if indexPath.section == 1 {
            var activity = self.nonAcesActivities[indexPath.row] as Context
            activityIconURL = activity.extras
            cell.textLabel?.text = activity.title
        }
        
        loadImageFromWeb(activityIconURL, cell: cell, index: indexPath.row)

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            if cell?.textLabel?.text == "How Many Mallards?" {
                self.performSegueWithIdentifier("birdActivity", sender: indexPath)
            } else {
                self.performSegueWithIdentifier("activityDetail", sender: indexPath)
            }
        }
        if indexPath.section == 1 {
            self.performSegueWithIdentifier("activityDetail", sender: indexPath)
        }

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "activityDetail" {
            let destinationVC = segue.destinationViewController as! ActivityDetailTableViewController
            // if passed from a cell
            if let indexPath = sender as? NSIndexPath {
                var selectedActivity: Context!
                if indexPath.section == 0 {
                    selectedActivity = acesActivities[indexPath.row]
                }
                
                if indexPath.section == 1 {
                    selectedActivity = nonAcesActivities[indexPath.row]
                }
                
                destinationVC.activity = selectedActivity
            }
        }
        
        if segue.identifier == "birdActivity" {
            let destinationVC = segue.destinationViewController as! BirdActivityTableViewController
            if let indexPath = sender as? NSIndexPath {
                var activity = self.acesActivities[indexPath.row] as Context
                // destinationVC.activity = activity
                destinationVC.activityDescription = activity.context_description
                destinationVC.navigationItem.title = activity.title
                let birdsURLs = activity.extras as NSString

                if let data = birdsURLs.dataUsingEncoding(NSUTF8StringEncoding)  {
                    let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSDictionary
                    destinationVC.activityThumbURL = json["Icon"] as! String
                    let birdsJSON = json["Birds"] as? [NSDictionary]
                    let birds = self.convertBirdJSONToBirds(birdsJSON!)
//                    destinationVC.birds = birds
                }
            }
        }

    }
    
    private func loadActivities() {
//        if Session.isSignedIn() {
//            if let site: Site = Session.getSite() {
//                let siteContexts = site.getContexts()
//                for sContext in siteContexts {
//                    let context = sContext as! Context
//                    if context.kind == "Activity" {
//                        self.acesActivities.append(context)
//                    }
//                }
//            }
//        }
        
        
        let managedContext: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let predicate = NSPredicate(format: "kind = %@", "Activity")
        var activities:[Context] = SwiftCoreDataHelper.fetchEntities(NSStringFromClass(Context), withPredicate: predicate, managedObjectContext: managedContext) as! [Context]
        for activity in activities {
            if activity.kind == "Activity" {
                if activity.site_uid == 6 {
                    self.nonAcesActivities.append(activity)
                }
                
                if activity.site_uid == 2 {
                    self.acesActivities.append(activity)
                }
            }
            
        }
        
        
    }
    
    private func loadImageFromWeb(iconURL: String, cell: UITableViewCell, index: Int ) {
        if let url = NSURL(string: iconURL) {
            let urlRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
                response, data, error in
                if error != nil {
                    
                    
                } else {
                    let image = UIImage(data: data)
                    cell.imageView?.image = image
                }
            })
        }
      
    }
    
    // give a JSON output an array of BirdCount (defined in BirdCountingTableViewController)
    private func convertBirdJSONToBirds(birdsJSON: [NSDictionary]) -> [BirdCountingTableViewController.BirdCount] {
        var birds: [BirdCountingTableViewController.BirdCount] = []
        for birdJSON in birdsJSON {
            var bird = BirdCountingTableViewController.BirdCount()
            if let name = birdJSON["name"] as? String {
                bird.name = name
            }
            if let url = birdJSON["image"] as? String {
                bird.thumbnailURL = url
            }
            bird.count = 0
            birds.append(bird)
        }
        
        return birds
    }
    
    func refreshActivityList() {
//        self.refreshControl?.attributedTitle = NSString("Last Upate: ")
        var parseService = APIService()

        Site.doPullByNameFromServer(parseService, name: "aces")
        self.refreshControl?.endRefreshing()
    }
    
    // after getting data from server
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as! Int
            if (status == 400) {
                var errorMessage = "We didn't recognize your NatureNet Name or Password"
                return
            }
            
            // 600 is self defined error code on the phone's side
            if (status == 600) {
                var errorMessage = "Internet seems not working"
                // self.createAlert(errorMessage)
                return
            }
            
            if from == "Site" {
                var data = response["data"] as! NSDictionary!
                var model = data["_model_"] as! String
                self.handleSiteData(data)
            }
        })
    }
    
    // !!!if site exists, no update, should check modified date is changed!! but no modified date returned from API
    func handleSiteData(data: NSDictionary) {
        var sitename = data["name"] as! String
        let predicate = NSPredicate(format: "name = %@", "aces")
        let exisitingSite = NNModel.fetechEntitySingle(NSStringFromClass(Site), predicate: predicate) as? Site
        if exisitingSite != nil {
            // println("You have aces site in core data: "  + exisitingSite!.toString())
            // should check if modified date is changed here!! but no modified date returned from API
            exisitingSite!.updateToCoreData(data)
        } else {
//            self.site = Site.saveToCoreData(data)
        }
    }



}
