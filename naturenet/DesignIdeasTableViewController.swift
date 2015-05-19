//
//  DesignIdeasTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 5/13/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class DesignIdeasTableViewController: UITableViewController, APIControllerProtocol, SaveInputStateProtocol {

    var ideaActivities: [Context] = []
    
    let ACESSITENAME = "aces"
    var designIdeaInput: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadActivities()
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true
        self.refreshControl?.tintColor = UIColor.darkGrayColor()
        self.refreshControl?.addTarget(self, action: "refreshActivityList", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int!
        if section == 0 {
            rows = ideaActivities.count
        }
        return rows
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var headerTitle: String!
        if section == 0 {
            headerTitle = "Design Ideas"
        }
        return headerTitle
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("designIdeaListCell", forIndexPath: indexPath) as! UITableViewCell
        var activityIconURL: String!
        var isJSONActivity: Bool = false
        
        if indexPath.section == 0 {
            var activity = self.ideaActivities[indexPath.row] as Context
            cell.textLabel?.text = activity.title
            let birdsURLs = activity.extras as NSString
            // check the link is in a JSON String or not, if it is in a JSON object, get the value from "Icon" key
            if let data = birdsURLs.dataUsingEncoding(NSUTF8StringEncoding)  {
                if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                    if let isBirdActivity = json["type"] as? String {
                        isJSONActivity = true
                    }
                    activityIconURL = json["Icon"] as! String
                    
                } else {
                    activityIconURL = birdsURLs as String
                }
            } else {
                activityIconURL = birdsURLs as String
            }
          
        }
        loadImageFromWeb(ImageHelper.createThumbCloudinaryLink(activityIconURL, width: 128, height: 128), cell: cell, index: indexPath.row)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            self.performSegueWithIdentifier("designIdeaDetail", sender: indexPath)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "designIdeaDetail" {
            let destinationVC = segue.destinationViewController as! DesignIdeaDetailTableViewController
            // if passed from a cell
            if let indexPath = sender as? NSIndexPath {
                var selectedActivity: Context!
                if indexPath.section == 0 {
                    selectedActivity = ideaActivities[indexPath.row]
                }
                destinationVC.delegate = self
                destinationVC.activity = selectedActivity
                destinationVC.designIdeaSavedInput = self.designIdeaInput
            }
        }
        
    }
    
    // load activities for this tableview
    private func loadActivities() {
        if let acesSite = Session.getSiteByName(ACESSITENAME) {
            self.ideaActivities = Session.getActiveContextsBySite("Design", site: acesSite) as [Context]
            // sort the list of ideas
            self.ideaActivities.sort({ $0.uid.compare($1.uid) == NSComparisonResult.OrderedDescending })
        }
    }
    
    private func loadImageFromWeb(iconURL: String, cell: UITableViewCell, index: Int ) {
        if let url = NSURL(string: iconURL) {
            let urlRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
                response, data, error in
                if error != nil {
                    let image = UIImage(named: "networkerror")
                    cell.imageView?.image = image
                    
                } else {
                    let image = UIImage(data: data)
                    cell.imageView?.image = image
                }
            })
        }
        
    }
    
    
    // pull to refresh
    @IBAction func refreshActivityList() {
        var parseService = APIService()
        parseService.delegate = self
        Site.doPullByNameFromServer(parseService, name: "aces")
    }
    
    // implement saveInputState to conform SaveInputStateProtocol
    func saveInputState(input: String?) {
        self.designIdeaInput = input
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
            if (status == APIService.CRASHERROR) {
                var errorMessage = "Internet seems not working"
                // self.createAlert(errorMessage)
                return
            }
            
            if from == "Site" {
                var data = response["data"] as! NSDictionary!
                var model = data["_model_"] as! String
                self.handleSiteData(data)
            }
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()

        })
    }
    
    // !!!if site exists, no update, should check modified date is changed!! but no modified date returned from API
    func handleSiteData(data: NSDictionary) {
        var sitename = data["name"] as! String
        let predicate = NSPredicate(format: "name = %@", sitename)
        let exisitingSite = NNModel.fetechEntitySingle(NSStringFromClass(Site), predicate: predicate) as? Site
        if exisitingSite != nil {
            // should check if modified date is changed here!! but no modified date returned from API
            exisitingSite!.updateToCoreData(data)
        } else {
            //            self.site = Site.saveToCoreData(data)
        }
    }
}
