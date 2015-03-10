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


protocol SaveObservationProtocol {
    func saveObservation(note: Note, media: Media?, feedback: Feedback?) -> Void
}

class ObservationDetailController: UITableViewController, CLLocationManagerDelegate {

    // UI Outlets
    @IBOutlet weak var noteImageView: UIImageView!
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet var observationTableView: UITableView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var activityLable: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    let locationManager = CLLocationManager()
    
    // data passed from previous page
    var noteIdFromObservations: NSManagedObjectID?
    var imageFromCamera: UIImage?
    var activityNameFromActivityDetail: String?
    var sourceViewController: String?
    var saveObservationDelegate: SaveObservationProtocol?
    
    var noteMedia: Media?
    var note: Note?
    var feedback: Feedback?
    var activities = [Context]()
    var landmarks = [Context]()
    
    // data for this page
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
    
    // didSelectRowAtIndexPath
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row {
        case 0 :
            self.performSegueWithIdentifier("editObsToDescription", sender: self)
        case 1 :
            self.performSegueWithIdentifier("editObsToActivity", sender: self)
        case 2 :
            self.performSegueWithIdentifier("editObsToLocation", sender: self)
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
            destinationVC.noteContent = descriptionLabel.text
        }
        if segue.identifier == "editObsToActivity" {
            let destinationVC = segue.destinationViewController as NoteActivitySelectionViewController
            destinationVC.activities = self.activities
            destinationVC.selectedActivityTitle = activityLable.text
        }
        if segue.identifier == "editObsToLocation" {
            let destinationVC = segue.destinationViewController as NoteLocationTableViewController
            destinationVC.landmarks = self.landmarks
            destinationVC.selectedLocation = locationLabel.text
        }
        
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // IBActions for receiced data passed back
    //----------------------------------------------------------------------------------------------------------------------
    
    // receive data from note description textview
    @IBAction func passedDescription(segue:UIStoryboardSegue) {
        let noteDescriptionVC = segue.sourceViewController as NoteDescriptionViewController
        if let desc = noteDescriptionVC.noteContent {
            descriptionLabel.text = desc
        }
        self.navigationItem.rightBarButtonItem?.style = .Done
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // receive data from activity selection
    @IBAction func passedActivitySelection(segue:UIStoryboardSegue) {
        let noteActivitySelectionVC = segue.sourceViewController as NoteActivitySelectionViewController
        if let activityTitle = noteActivitySelectionVC.selectedActivityTitle {
            activityLable.text = activityTitle
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // receive data from activity selection
    @IBAction func passedLocationSelection(segue:UIStoryboardSegue) {
        let noteLocationSelectionVC = segue.sourceViewController as NoteLocationTableViewController
        if let locationTitle = noteLocationSelectionVC.selectedLocation {
            locationLabel.text = locationTitle
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendPressed(sender: UIBarButtonItem) {
        if sourceViewController == NSStringFromClass(ActivityDetailViewController)
            || sourceViewController == NSStringFromClass(TourViewController)
            || sourceViewController == NSStringFromClass(LocationDetailViewController) {
            let nextViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ObservationsViewController")
                                    as ObservationsController
            self.navigationController?.pushViewController(nextViewController, animated: true)
            nextViewController.sourceViewController = sourceViewController
            self.saveNote()
//            self.saveObservationDelegate = nextViewController
//            nextViewController.cameraImage = self.imageFromCamera
//            self.saveObservationDelegate?.saveObservation(self.note!, media: self.noteMedia, feedback: self.feedback)
            nextViewController.receivedNoteFromObservation = self.note
        }
        
        if sourceViewController == NSStringFromClass(ObservationsController) {
            self.navigationController?.popViewControllerAnimated(true)
            if self.imageFromCamera != nil {
                self.saveNote()
                self.saveObservationDelegate?.saveObservation(self.note!, media: self.noteMedia, feedback: self.feedback)
            } else {
                self.updateNote()
                self.saveObservationDelegate?.saveObservation(self.note!, media: nil, feedback: self.feedback)
            }
        }
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
        // update current location as the location selection
        var landmarkName = determineLandmarkByLocation(self.userLat!, lon: self.userLon!)
        self.locationLabel.text = landmarkName
    }
    
    // implement location didFailWithError
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error happened locationmanager \(error.domain)")
        var message = "NatureNet requires to acess your location"
        noLocationAlert(message)

    }
    
    func noLocationAlert(message: String) {
        var alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        var okAction = UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            return
        })
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func determineLandmarkByLocation(lat: CLLocationDegrees, lon: CLLocationDegrees) -> String {
        let latError = 0.0001;
        let lonError = 0.0001;
        var name: String = "Other"

        for landmark in self.landmarks {
            if let location = landmark.getCoordinatesForLandmark() {
                if (abs(lat - location.latitude) < latError
                    && abs(lon - location.longitude) < lonError) {
                        name = landmark.title
                        break
                }
            }
        }
        return name
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // save note
    //----------------------------------------------------------------------------------------------------------------------

    func saveNote() -> Note {
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var mNote = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as Note
        if imageFromCamera != nil {
            if userLon != nil && userLat != nil {
                mNote.longitude = self.userLon!
                mNote.latitude = self.userLat!
            }
        }
        var account = Session.getAccount()
        mNote.account = account!
        mNote.kind = "FieldNote"
        mNote.state = NNModel.STATE.NEW
        if let desc = descriptionLabel.text {
            mNote.content = desc
        }
        
        if let activity = activityLable.text {
            var selectedActivity = getActivityByName(activity)!
            mNote.context = selectedActivity
        }
        
        var timestamp = UInt64(floor(NSDate().timeIntervalSince1970 * 1000))
        var createdAt = NSNumber(unsignedLongLong: timestamp)
        mNote.created_at = createdAt
        mNote.modified_at = createdAt
        
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
        if let landmark = locationLabel.text {
            var selectedLandmark = getLandmarkByName(landmark)!
            var feedback = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Feedback), managedObjectConect: nsManagedContext) as Feedback
            feedback.account = account!
            feedback.state = NNModel.STATE.NEW
            feedback.kind = "landmark"
            feedback.note = mNote
            feedback.target_model = "Note"
            feedback.content = selectedLandmark.name
            feedback.created_at = Double(createdAt)
            self.feedback = feedback
            feedback.commit()
        }
        
        mNote.commit()
        self.note = mNote
        return mNote
    }
    
    // update note 
    func updateNote() -> Note {
        if let desc = descriptionLabel.text {
            note!.content = desc
        }
        if let activity = activityLable.text {
            var selectedActivity = getActivityByName(activity)!
            note!.context = selectedActivity
        }
        if let landmark = locationLabel.text {
            var selectedLandmark = getLandmarkByName(landmark)!
            var predicate = NSPredicate(format: "note = %@", note!.objectID)
            var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
            var fetchedFeedback = SwiftCoreDataHelper.fetchEntitySingle(NSStringFromClass(Feedback), withPredicate: predicate,
                managedObjectContext: nsManagedContext) as Feedback?
            if fetchedFeedback != nil {
                fetchedFeedback!.content = selectedLandmark.name
                fetchedFeedback!.commit()
            }
            feedback = fetchedFeedback
        }

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
        
        // this step looks neccessary for set descriptionLabel text consistently
        descriptionLabel.text = " "
        
        // load note informaiton, e.g. description/media image
        if let noteObjectID = self.noteIdFromObservations {
            var predicate = NSPredicate(format: "SELF = %@", noteObjectID)
            if let mNote = SwiftCoreDataHelper.fetchEntitySingle(NSStringFromClass(Note), withPredicate: predicate,
                managedObjectContext: SwiftCoreDataHelper.nsManagedObjectContext) as Note? {
                   self.note = mNote
            }
            self.noteMedia = self.note?.getSingleMedia()
            descriptionLabel.text = note!.content
            
            var noteActivity = note!.context
            activityLable.text = noteActivity.title
            imageLoadingIndicator.startAnimating()
            if let fullPath = noteMedia?.full_path {
                let fileManager = NSFileManager.defaultManager()
                if fileManager.fileExistsAtPath(fullPath) {
                    // println("you clicked an image with full path in ObservationDetailController: \(fullPath)")
                    let image = UIImage(named: fullPath)
                    self.noteImageView.image = image
                    self.imageLoadingIndicator.stopAnimating()
                    self.imageLoadingIndicator.removeFromSuperview()
                }
            }
            
            if self.noteImageView.image == nil {
                loadFullImage(noteMedia!)
            }
            
            var landmarkTitle = getLandmarkTitle(self.note!, contexts: self.landmarks)!
            locationLabel.text = landmarkTitle
        } else if self.imageFromCamera != nil {
            self.noteImageView.image = self.imageFromCamera!
            imageLoadingIndicator.stopAnimating()
            imageLoadingIndicator.removeFromSuperview()
            if let activityTitle = self.activityNameFromActivityDetail {
                activityLable.text = activityTitle
            } else {
                activityLable.text = "Free Observation"
            }
            descriptionLabel.text = descriptionLabel.text
            locationLabel.text = "Other"
            
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
        var fileName = String(media.created_at.longLongValue) + ".jpg"
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
