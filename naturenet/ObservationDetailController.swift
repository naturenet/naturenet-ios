//
//  ObservationDetailController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/3/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ObservationDetailController: UIViewController, UITableViewDelegate, CLLocationManagerDelegate, CLUploaderDelegate {

    // UI Outlets
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var detailTableView: UITableView!
    
    let locationManager = CLLocationManager()
    var cloudinary:CLCloudinary = CLCloudinary()
    
    // data passed from previous page
    var noteIdFromObservations: NSManagedObjectID?
    var imageFromCamera: UIImage?
    var noteMedia: Media?
    var note: Note?
    var feedback: Feedback?
    var activities = [Context]()
    var landmarks = [Context]()
    
    // data for this page
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    
    // tableview data
    var titles = ["Description", "Activity", "Location"]
    var details = [" ", "Free Observation", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.detailTableView.reloadData()
        loadData()
        // only request location on new observation
        if imageFromCamera != nil {
            initLocationManager()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // tableView setup
    //----------------------------------------------------------------------------------------------------------------------
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

    // didSelectRowAtIndexPath
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
    
    //----------------------------------------------------------------------------------------------------------------------
    // segues setup
    //----------------------------------------------------------------------------------------------------------------------
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
    
    //----------------------------------------------------------------------------------------------------------------------
    // IBActions for receiced data passed back
    //----------------------------------------------------------------------------------------------------------------------
    
    // receive data from note description textview
    @IBAction func passedDescription(segue:UIStoryboardSegue) {
        let noteDescriptionVC = segue.sourceViewController as NoteDescriptionViewController
        if let desc = noteDescriptionVC.noteContent {
            details[0] = desc
            self.detailTableView.reloadData()
        }
        self.navigationItem.rightBarButtonItem?.style = .Done
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    // receive data from activity selection
    @IBAction func passedActivitySelection(segue:UIStoryboardSegue) {
        let noteActivitySelectionVC = segue.sourceViewController as NoteActivitySelectionViewController
        if let activityTitle = noteActivitySelectionVC.selectedActivityTitle {
            details[1] = activityTitle
        }
        self.detailTableView.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // receive data from activity selection
    @IBAction func passedLocationSelection(segue:UIStoryboardSegue) {
        let noteLocationSelectionVC = segue.sourceViewController as NoteLocationTableViewController
        if let locationTitle = noteLocationSelectionVC.selectedLocation {
            details[2] = locationTitle
        }
        self.detailTableView.reloadData()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // LocationManager
    //----------------------------------------------------------------------------------------------------------------------
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
    
    //----------------------------------------------------------------------------------------------------------------------
    // save note
    //----------------------------------------------------------------------------------------------------------------------

    func saveNote() -> Note {
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var mNote = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as Note
        if imageFromCamera != nil {
            mNote.longitude = self.userLon!
            mNote.latitude = self.userLat!
        }
        var account = Session.getAccount()
        mNote.account = account!
        mNote.kind = "FieldNote"
        mNote.state = NNModel.STATE.NEW
        mNote.content = details[0]
        var selectedActivity = getActivityByName(details[1])!
        mNote.context = selectedActivity
        
        var timestamp = UInt64(floor(NSDate().timeIntervalSince1970 * 1000))
        var createdAt = NSNumber(unsignedLongLong: timestamp)
        mNote.created_at = createdAt
        
        // save to Media
        var fileName = String(timestamp) + ".jpg"
        UIImageWriteToSavedPhotosAlbum(self.noteImageView.image!, nil, nil, nil)
        var fullPath = ObservationCell.saveToDocumentDirectory(UIImagePNGRepresentation(self.noteImageView.image), name: fileName)
        var media = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Media), managedObjectConect: nsManagedContext) as Media
        media.note = mNote
        media.state = NNModel.STATE.NEW
        media.full_path = fullPath
        media.created_at = createdAt
        self.noteMedia = media
        media.commit()
        
        // save to Feedback
        var selectedLandmark = getLandmarkByName(details[2])!
        var feedback = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Feedback), managedObjectConect: nsManagedContext) as Feedback
        feedback.account = account!
        feedback.state = NNModel.STATE.NEW
        feedback.kind = "landmark"
        feedback.note = mNote
        feedback.target_model = "Note"
        feedback.content = selectedLandmark.name
        feedback.created_at = createdAt
        self.feedback = feedback
        feedback.commit()
        
        mNote.commit()
        return mNote
    }
    
    // update note 
    func updateNote() -> Note {
        note!.content = details[0]
        var selectedActivity = getActivityByName(details[1])!
        note!.context = selectedActivity
        var selectedLandmark = getLandmarkByName(details[2])!
        var predicate = NSPredicate(format: "note = %@", note!.objectID)
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var fetchedFeedback = SwiftCoreDataHelper.fetchEntitySingle(NSStringFromClass(Feedback), withPredicate: predicate,
                                managedObjectContext: nsManagedContext) as Feedback?
        if fetchedFeedback != nil {
            fetchedFeedback!.content = selectedLandmark.name
            fetchedFeedback!.commit()
        }
        self.feedback = fetchedFeedback
        
//        var fetchedMedia = SwiftCoreDataHelper.fetchEntitySingle(NSStringFromClass(Media), withPredicate: predicate,
//            managedObjectContext: nsManagedContext) as Media?
//        if fetchedMedia != nil {
//            fetchedMedia!.commit()
//        }
//        self.noteMedia = fetchedMedia
        note!.commit()
        return self.note!
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // some utility functions
    //----------------------------------------------------------------------------------------------------------------------

    // load data for this view
    func loadData() {
        // load landmarks and activities (type: Context)
        loadContexts()
        // load note informaiton, e.g. description/media image
        if let noteObjectID = self.noteIdFromObservations {
            var predicate = NSPredicate(format: "SELF = %@", noteObjectID)
            if let mNote = SwiftCoreDataHelper.fetchEntitySingle(NSStringFromClass(Note), withPredicate: predicate,
                managedObjectContext: SwiftCoreDataHelper.nsManagedObjectContext) as Note? {
                   self.note = mNote
            }
//            self.note = noteMedia?.getNote()
            self.noteMedia = self.note?.getSingleMedia()
            
            details[0] = note!.content
            
            var noteActivity = note!.context
            details[1] = noteActivity.title
            imageLoadingIndicator.startAnimating()
            if let fullPath = noteMedia?.full_path {
                let fileManager = NSFileManager.defaultManager()
                if fileManager.fileExistsAtPath(fullPath) {
                    println("you clicked an image with full path in ObservationDetailController: \(fullPath)")
                    let image = UIImage(named: fullPath)
                    self.noteImageView.image = image
                    self.imageLoadingIndicator.stopAnimating()
                    self.imageLoadingIndicator.removeFromSuperview()
                } else {
                    println("full path doesn't exist")
                }
            }
            
            if self.noteImageView.image == nil {
                loadFullImage(noteMedia!)
            }
            
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
    func loadFullImage(media: Media) {
        var url = media.url!
        // println("passed image url is: \(url)")
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
                self.saveFullImage(data, media: media)
            }
        })
    }
    
    // func 
    func saveFullImage(data: NSData, media: Media) {
        var fileName = String(media.created_at.integerValue) + ".jpg"
        var tPath: String = ObservationCell.saveToDocumentDirectory(data, name: fileName)!
        media.full_path = tPath
        media.setLocalFullPath(tPath)

    }
    
    // get landmark locaiton titles
    func getLandmarkTitle(note: Note, contexts: [Context]) -> String? {
        var feedbacks = note.getFeedbacks()
        var title: String?
        for feedback in feedbacks {
            // ?? not sure this is the right way to get landmark feedback
            var landmarkFeedback = feedback as Feedback
            for context in contexts {
                if landmarkFeedback.content == context.name {
                    title = context.title
                }
            }
            
        }
        return title
    }
    
    func getActivityByName(name: String) -> Context? {
        var rActivity: Context?
        for activity in activities {
            if activity.title == name {
                rActivity = activity
                break
            }
        }
        return rActivity
    }
    
    func getLandmarkByName(name: String) -> Context? {
        var rLandmark: Context?
        for landmark in landmarks {
            if landmark.title == name {
                rLandmark = landmark
                break
            }
        }
        return rLandmark
    }

}
