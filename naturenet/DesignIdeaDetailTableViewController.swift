//
//  DesignIdeaDetailTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 5/13/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class DesignIdeaDetailTableViewController: UITableViewController, APIControllerProtocol {

    var activity: Context!
    var cameraImage: UIImage!
    var apiService = APIService()
    var notesInActivtity: [Note]?
    
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var iconActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ideaTextView: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        apiService.delegate = self
        ideaTextView.layer.cornerRadius = 5
        ideaTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        ideaTextView.layer.borderWidth = 1
     
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // self.edgesForExtendedLayout = UIRectEdge.None
        
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    
    private func setupView() {
        var iconURL = activity.extras
        if let data = iconURL.dataUsingEncoding(NSUTF8StringEncoding)  {
            if let json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: nil) as? NSDictionary {
                iconURL = json["Icon"] as! String
                ImageHelper.loadImageFromWeb(iconURL, imageview: activityIconImageView, indicatorView: iconActivityIndicator)            }
        }
        
        self.navigationItem.title = activity.title
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 180.0
        activityDescriptionLabel.text = activity.context_description
    }
    
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // segues setup
    //----------------------------------------------------------------------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "activityToObservation" {
          
        }
    }
    
    // implement didReceiveResults to conform APIControllerProtocol
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) {
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as! Int
            if status == 600 {
                let alertTitle = "Internet Connection Problem"
                let alertMessage = "Please check your Internet connection"
                AlertControllerHelper.createGeneralAlert(alertTitle, message: alertMessage, controller: self)
                return
            }
            
            var uid = response["data"]!["id"] as! Int
            if from == "POST_" + NSStringFromClass(Note) {
                println("now after post_note, ready for uploading feedbacks")
                var modifiedAt = response["data"]!["modified_at"] as! NSNumber
                if let newNote = sourceData as? Note {
                    newNote.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                    newNote.doPushFeedbacks(self.apiService)
                    if let newNoteMedia = newNote.getSingleMedia() {
                        if newNoteMedia.url != nil {
                        } else {
                            newNoteMedia.apiService = self.apiService
                            newNoteMedia.uploadToCloudinary()
                        }
                    }
                }
            }
            if from == "POST_" + NSStringFromClass(Feedback) {
                println("now after post_feedback, if this is a new note, ready for uploading to cloudinary, otherwise, do update")
                var modifiedAt = response["data"]!["modified_at"] as! NSNumber
                if let newNoteFeedback = sourceData as? Feedback {
                    newNoteFeedback.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                }
            }
            if from == "POST_" + NSStringFromClass(Media) {
                println("now after post_media")
                if let newNoteMedia = sourceData as? Media {
                    newNoteMedia.updateAfterPost(uid, modifiedAtFromServer: nil)
                    
                }
            }
        })
        
    }


}
