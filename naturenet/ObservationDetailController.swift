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
    var imageFromObservation: ObservationsController.PickedImage?
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
        
        loadData()
        // only request location on new observation
        if imageFromObservation != nil {
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
        if indexPath.section == 1 {
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
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // segues setup
    //----------------------------------------------------------------------------------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "editObsToDescription" {
            let destinationVC = segue.destinationViewController as! NoteDescriptionViewController
            destinationVC.noteContent = descriptionLabel.text
        }
        if segue.identifier == "editObsToActivity" {
            let destinationVC = segue.destinationViewController as! NoteActivitySelectionViewController
            destinationVC.activities = self.activities
            destinationVC.selectedActivityTitle = activityLable.text
        }
        if segue.identifier == "editObsToLocation" {
            let destinationVC = segue.destinationViewController as! NoteLocationTableViewController
            destinationVC.landmarks = self.landmarks
            destinationVC.selectedLocation = locationLabel.text
        }
        
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // IBActions for receiced data passed back
    //----------------------------------------------------------------------------------------------------------------------
    
    // receive data from note description textview
    @IBAction func passedDescription(segue:UIStoryboardSegue) {
        let noteDescriptionVC = segue.sourceViewController as! NoteDescriptionViewController
        if let desc = noteDescriptionVC.noteContent {
            descriptionLabel.text = desc
        }
        self.navigationItem.rightBarButtonItem?.style = .Done
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // receive data from activity selection
    @IBAction func passedActivitySelection(segue:UIStoryboardSegue) {
        let noteActivitySelectionVC = segue.sourceViewController as! NoteActivitySelectionViewController
        if let activityTitle = noteActivitySelectionVC.selectedActivityTitle {
            activityLable.text = activityTitle
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // receive data from activity selection
    @IBAction func passedLocationSelection(segue:UIStoryboardSegue) {
        let noteLocationSelectionVC = segue.sourceViewController as! NoteLocationTableViewController
        if let locationTitle = noteLocationSelectionVC.selectedLocation {
            locationLabel.text = locationTitle
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func cancelPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendPressed(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
        if self.imageFromObservation != nil {
            self.saveNote()
            self.saveObservationDelegate?.saveObservation(self.note!, media: self.noteMedia, feedback: self.feedback)
        } else {
            self.updateNote()
            self.saveObservationDelegate?.saveObservation(self.note!, media: nil, feedback: self.feedback)
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
        var userLocation: CLLocation = locations[0] as! CLLocation
        self.userLat = userLocation.coordinate.latitude
        self.userLon = userLocation.coordinate.longitude
        self.locationManager.stopUpdatingLocation()
        // testing
        // var userLocation = CLLocation(latitude: 39.195698, longitude: -106.822153)
        // update current location as the location selection
        var landmarkName = determineLandmarkByLocation(userLocation)
        // println("detected location is: \(landmarkName)");
        self.locationLabel.text = landmarkName
    }
    
    // implement location didFailWithError
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // println("error happened locationmanager \(error.domain)")
        var message = "NatureNet requires to acess your location"
        AlertControllerHelper.noLocationAlert(message, controller: self)
    }
    
    // @Deprecated
    // old way to determine landmark location
    func determineLandmarkByLocation(lat: CLLocationDegrees, lon: CLLocationDegrees) -> String {
        let latError = 0.0001;
        let lonError = 0.0001;
        var name: String = "Other"

        for landmark in self.landmarks {
            if let location = landmark.getCoordinatesForLandmark() {
                if (abs(lat - location.coordinate.latitude) < latError
                    && abs(lon - location.coordinate.longitude) < lonError) {
                        name = landmark.title
                        break
                }
            }
        }
        return name
    }
    
    // a new way, always choose the closest location as long as the locaiton is in the park
    func determineLandmarkByLocation(userLocaiton: CLLocation) -> String {
        let upleftLat = 39.199845
        let upleftLon = -106.824084
        let bottomrightLat = 39.194026
        let bottomrightLon = -106.819499
        
        var name: String = "Other"
        let locationLon = userLocaiton.coordinate.longitude
        let locationLat = userLocaiton.coordinate.latitude
        
        // make sure the user is in the park
        if locationLat < upleftLat && locationLat > bottomrightLat
            && locationLon < bottomrightLon && locationLon > upleftLon {
            var minDistance = 2000.0  // unit meter
            for landmark in self.landmarks {
                if let location = landmark.getCoordinatesForLandmark() {
                    var distance: CLLocationDistance = userLocaiton.distanceFromLocation(location)
                    if distance < minDistance {
                        minDistance = distance
                        name = landmark.title
                    }
                }
            }
        }

        return name
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // save note
    //----------------------------------------------------------------------------------------------------------------------

    func saveNote() -> Note {
        var timestamp = UInt64(floor(NSDate().timeIntervalSince1970 * 1000))
        var createdAt = NSNumber(unsignedLongLong: timestamp)
        
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var mNote = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as! Note
        if imageFromObservation != nil {
            if userLon != nil && userLat != nil {
                mNote.longitude = self.userLon!
                mNote.latitude = self.userLat!
            }

            if !self.imageFromObservation!.isFromGallery {
                UIImageWriteToSavedPhotosAlbum(self.noteImageView.image!, nil, nil, nil)
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
            if let selectedActivity = getActivityByName(activity) {
                mNote.context = selectedActivity
            }
        }
        
        mNote.created_at = createdAt
        mNote.modified_at = createdAt
        
        // save to Media
        self.noteMedia = mNote.doSaveMedia(self.noteImageView.image!, timestamp: timestamp)
        
        // save to Feedback
        if let landmark = locationLabel.text {
            var selectedLandmark = getLandmarkByName(landmark)!
            self.feedback = mNote.doSaveFeedback(selectedLandmark, timestamp: timestamp)
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
                managedObjectContext: nsManagedContext) as! Feedback?
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
                managedObjectContext: SwiftCoreDataHelper.nsManagedObjectContext) as! Note? {
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
        } else if self.imageFromObservation != nil {
            self.noteImageView.image = self.imageFromObservation!.image
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
        self.landmarks = Session.getContexts("Landmark")
        self.activities = Session.getActiveContextsBySite("Activity", site: nil)
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
            var landmarkFeedback = feedback as! Feedback
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
