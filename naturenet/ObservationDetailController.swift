//
//  ObservationDetailController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/3/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreLocation

class ObservationDetailController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate {

    // UI Outlets
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var detailTableView: UITableView!
    
    let locationManager = CLLocationManager()
    
    // data passed from previous page
    var mediaIdFromObservations: Int?
    var imageFromCamera: UIImage?
    var noteMedia: Media?
    var note: Note?
    var activities = [Context]()
    var landmarks = [Context]()
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    
    
    // tableview data
    var titles = ["Description", "Activity", "Location"]
    var details = ["", "Free Observation", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadData()
        self.detailTableView.reloadData()
        // only request location on new observation
        if imageFromCamera != nil {
            initLocationManager()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "profilecell")
        let cell = tableView.dequeueReusableCellWithIdentifier("editObsCell", forIndexPath: indexPath) as EditObsTableViewCell
        cell.editCellTitle!.text = titles[indexPath.row]
        cell.editCellDetail!.text = details[indexPath.row]
        return cell
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editObsToDescription" {
            let destinationVC = segue.destinationViewController as NoteDescriptionViewController
            destinationVC.noteContent = details[0]
        }
        if segue.identifier == "selectObsActivitySeg" {
            let destinationVC = segue.destinationViewController as NoteActivitySelectionViewController
            destinationVC.activities = self.activities
            destinationVC.selectedActivityTitle = details[1]
        }
        if segue.identifier == "selectObsLocationSeg" {
            let destinationVC = segue.destinationViewController as NoteLocationTableViewController
            destinationVC.landmarks = self.landmarks
            destinationVC.selectedLocation = details[2]
        }

    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0 :
            self.performSegueWithIdentifier("editObsToDescription", sender: self)
        case 1 :
            self.performSegueWithIdentifier("selectObsActivitySeg", sender: self)
        case 2 :
            self.performSegueWithIdentifier("selectObsLocationSeg", sender: self)
        default:
            return
        }
    }
    
    // receive data from note description textview
    @IBAction func passedDescription(segue:UIStoryboardSegue) {
        let noteDescriptionVC = segue.sourceViewController as NoteDescriptionViewController
        if let desc = noteDescriptionVC.noteContent {
            details[0] = desc
        }
        self.navigationController?.popViewControllerAnimated(true)
        self.detailTableView.reloadData()
    }
    
    
    // receive data from activity selection
    @IBAction func passedActivitySelection(segue:UIStoryboardSegue) {
        let noteActivitySelectionVC = segue.sourceViewController as NoteActivitySelectionViewController
        if let activityTitle = noteActivitySelectionVC.selectedActivityTitle {
            details[1] = activityTitle
        }
        self.navigationController?.popViewControllerAnimated(true)
        self.detailTableView.reloadData()
    }
    
    // receive data from activity selection
    @IBAction func passedLocationSelection(segue:UIStoryboardSegue) {
        let noteLocationSelectionVC = segue.sourceViewController as NoteLocationTableViewController
        if let locationTitle = noteLocationSelectionVC.selectedLocation {
            details[2] = locationTitle
        }
        self.navigationController?.popViewControllerAnimated(true)
        self.detailTableView.reloadData()
    }
    
    //----------------------------------------------------------------------------------------------
    // initialize locationManager
    func initLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    // implement location didUpdataLocation
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        println("location is  \(locations)")
        var userLocaiton: CLLocation = locations[0] as CLLocation
        self.userLat = userLocaiton.coordinate.latitude
        self.userLon = userLocaiton.coordinate.longitude
        self.locationManager.stopUpdatingLocation()
    }
    
    // implement location didFailWithError
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println(error)
    }
    
    //----------------------------------------------------------------------------------------------
    // save note
    func saveNote() {
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var mNote = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as Note
        if imageFromCamera != nil {
            mNote.longitude = self.userLon!
            mNote.latitude = self.userLat!
        }
        var account = Session.getAccount()
        mNote.account = account!
        mNote.kind = "FieldNote"
        mNote.content = details[0]
        
       
        UIImageWriteToSavedPhotosAlbum(self.imageFromCamera!, nil, nil, nil)
        var media = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Media), managedObjectConect: nsManagedContext) as Media
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
    }
    
    // update note 
    func updateNote() {
        self.note?.content = details[1]
    }
    
    //----------------------------------------------------------------------------------------------
    // some utility functions
    
    // load data for this view
    func loadData() {
        // load landmarks and activities (type: Context)
        loadContexts()
        
        // load note informaiton, e.g. description/media image
        if let mediaUID = self.mediaIdFromObservations {
            self.noteMedia = NNModel.doPullByUIDFromCoreData(NSStringFromClass(Media), uid: mediaUID) as Media?
            self.note = noteMedia?.getNote()
            details[0] = note!.content
            var noteActivity = note!.context
            details[1] = noteActivity.title
            imageLoadingIndicator.startAnimating()
            loadFullImage(noteMedia!.url)
            // println(" note info is: \(self.noteMedia!.getNote().toString()) media info: \(noteMedia!.toString()) ")
            // load note location info
            var landmarkTitle = getLandmarkTitle(self.note!, contexts: self.landmarks)!
            details[2] = landmarkTitle
        } else if self.imageFromCamera != nil {
            self.noteImageView.image = self.imageFromCamera!
            imageLoadingIndicator.stopAnimating()
            imageLoadingIndicator.removeFromSuperview()
        }
        
    }
    
    // initialize self.activities and self.landmarks
    func loadContexts() {
        if let site: Site = Session.getSite() {
            let siteContexts = site.getContexts()
            for sContext in siteContexts {
                let context = sContext as Context
                if context.kind == "Landmark" {
                    self.landmarks.append(context)
                }
                if context.kind == "Activity" {
                    self.activities.append(context)
                }
            }
        }
    }
    
    // load image into imageview
    func loadFullImage(url: String) {
        var nsurl: NSURL = NSURL(string: url)!
        let urlRequest = NSURLRequest(URL: nsurl)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
                
            } else {
                let image = UIImage(data: data)
                self.noteImageView.image = image
                self.imageLoadingIndicator.stopAnimating()
                self.imageLoadingIndicator.removeFromSuperview()
            }
        })
    }
    
    // get landmark locaiton titles
    func getLandmarkTitle(note: Note, contexts: [Context]) -> String? {
        var feedbacks = note.getFeedbacks()
        var title: String?
        for feedback in feedbacks {
            // ?? not sure this is the right way to get landmark feedback
            if feedback.kind == "Landmark" {
                var landmarkFeedback = feedback as Feedback
                for context in contexts {
                    if feedback.content == context.name {
                        title = context.title
                    }
                }
            }
        }
        return title
    }

}
