//
//  BirdCountingDetailTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/8/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreLocation

class BirdCountingDetailTableViewController: UITableViewController, UIPickerViewDelegate,
                                        UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    // UI elements
    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var numberPickerView: UIPickerView!
    @IBOutlet weak var numberTextLable: UILabel!
    @IBOutlet weak var previewImageview: UIImageView!
    
    // cells
    var numberPickerIsShowing = false
    let numberPickerCellIndexPathRow = 1
    let numberPickerCellIndexPathSection = 1
    let detailCellIndexPath = NSIndexPath(forRow: 0, inSection: 2)
    let locationCellIndexPath = NSIndexPath(forRow: 2, inSection: 2)

    // data
    let pickerData = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "10+"]
    var landmarks: [Context] = Session.getLandmarks()
    var prevImage: UIImage!
    var noteMedia: Media?
    var feedback: Feedback!
    var note: Note!
    
    // locationManager
    let locationManager = CLLocationManager()
    
    // data for this page
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    
    // delegate of 
    var saveObservationDelegate: SaveObservationProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButton()
        hideNumberPickerCell()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    private func customizeButton() {
        addPhotoBtn.titleLabel?.textAlignment = NSTextAlignment.Center
        addPhotoBtn.layer.cornerRadius = 0.5 * addPhotoBtn.bounds.size.width
        addPhotoBtn.layer.borderWidth = 1.0
        addPhotoBtn.layer.borderColor = UIColor.darkGrayColor().CGColor
        // addPhotoBtn.addTarget(self, action: "addPhotoButtonPressed", forControlEvents: .TouchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // tableView
    //----------------------------------------------------------------------------------------------------------------------

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableview: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = super.tableView(tableview, heightForRowAtIndexPath: indexPath)
        if indexPath.section == numberPickerCellIndexPathSection {
            if indexPath.row == numberPickerCellIndexPathRow  {
                if !self.numberPickerIsShowing {
                    height = 0
                }
            }
        }
        return height
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if indexPath.section == 1 {
            if indexPath.row == 0 {
                if self.numberPickerIsShowing {
                    self.hideNumberPickerCell()
                } else {
                    self.showNumberPickerCell()
                }
            }
            if indexPath.row == 2 {
                if self.numberPickerIsShowing {
                    self.hideNumberPickerCell()
                }
            }
        }
        
        if indexPath.section == 2 {
            // description input cell, programatically push NoteDescriptionViewController
            if indexPath.row == 0 {
                let nextViewController :NoteDescriptionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NoteDescriptionViewController")
                    as! NoteDescriptionViewController
                let cell = self.tableview.cellForRowAtIndexPath(self.detailCellIndexPath)!
                if cell.detailTextLabel?.text != "Detail" {
                    nextViewController.noteContent = cell.detailTextLabel?.text
                }
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
            
            if indexPath.row == 2 {
                let nextViewController :NoteLocationTableViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NoteLocationTableViewController")
                    as! NoteLocationTableViewController
                let cell = self.tableview.cellForRowAtIndexPath(self.locationCellIndexPath)!
                nextViewController.selectedLocation = cell.detailTextLabel?.text
                nextViewController.landmarks = self.landmarks
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
            
            if self.numberPickerIsShowing {
                self.hideNumberPickerCell()
            }
        }

    }
    
    private func showNumberPickerCell() {
        self.numberPickerIsShowing = true
        self.tableview.beginUpdates()
        self.tableview.endUpdates()
        self.numberPickerView.hidden = false
        
        
    }
    
    private func hideNumberPickerCell() {
        self.numberPickerIsShowing = false
        self.tableview.beginUpdates()
        self.tableview.endUpdates()
        self.numberPickerView.hidden = true
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // pickerView
    //----------------------------------------------------------------------------------------------------------------------
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPathForPicker = NSIndexPath(forRow: 0, inSection: 1)
        self.numberTextLable.text = pickerData[row]
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // pick from camera or gallary
    //----------------------------------------------------------------------------------------------------------------------
    @IBAction func openCamera() {
        var picker:UIImagePickerController = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)) {
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.presentViewController(picker, animated: true, completion: nil)
        } else {
            openGallary(picker)
        }
    }
    
    func openGallary(picker: UIImagePickerController!) {
        picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            self.presentViewController(picker, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.prevImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.previewImageview.image = prevImage
        self.addPhotoBtn.hidden = true
        self.previewImageview.hidden = false
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // IBActions for unwind segues from location list and activity list
    //----------------------------------------------------------------------------------------------------------------------
    
    // receive data from note description textview
    @IBAction func passedDescription(segue:UIStoryboardSegue) {
        let noteDescriptionVC = segue.sourceViewController as! NoteDescriptionViewController
        let cell = self.tableview.cellForRowAtIndexPath(self.detailCellIndexPath)!
        if let desc = noteDescriptionVC.noteContent {
            cell.detailTextLabel?.text = desc
        }
        self.navigationItem.rightBarButtonItem?.style = .Done
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // receive data from activity selection
    @IBAction func passedLocationSelection(segue:UIStoryboardSegue) {
        let noteLocationSelectionVC = segue.sourceViewController as! NoteLocationTableViewController
        let locationCell = self.tableview.cellForRowAtIndexPath(locationCellIndexPath)
        if let locationTitle = noteLocationSelectionVC.selectedLocation {
            locationCell?.detailTextLabel?.text = locationTitle
        }
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendPressed() {
        saveNote()
        self.saveObservationDelegate?.saveObservation(self.note, media: note.getSingleMedia(), feedback: note.getSignleFeedback())
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
        var landmarkName = determineLandmarkByLocation(userLocation)
        println("detected location is: \(landmarkName)")
        let landmarkCell = self.tableview.cellForRowAtIndexPath(locationCellIndexPath)
        landmarkCell?.detailTextLabel?.text = landmarkName
    }
    
    // implement location didFailWithError
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("error happened locationmanager \(error.domain)")
        var message = "NatureNet requires to acess your location"
        AlertControllerHelper.noLocationAlert(message, controller: self)
    }

    
    // save note
    private func saveNote()  {
        var timestamp = UInt64(floor(NSDate().timeIntervalSince1970 * 1000))
        var createdAt = NSNumber(unsignedLongLong: timestamp)
        
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var mNote = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as! Note
        if userLon != nil && userLat != nil {
            mNote.longitude = self.userLon!
            mNote.latitude = self.userLat!
        }
        UIImageWriteToSavedPhotosAlbum(self.previewImageview.image!, nil, nil, nil)

        var account = Session.getAccount()
        mNote.account = account!
        mNote.kind = "FieldNote"
        mNote.state = NNModel.STATE.NEW
        
        var numOfBirds = numberTextLable.text!
        let detailCell = self.tableview.cellForRowAtIndexPath(detailCellIndexPath)
        var content = detailCell?.detailTextLabel?.text
        let contentObject: [String : String] = ["type" : "bird", "number" : numOfBirds, "content": content!]
        let contentJSON = self.JSONStringify(contentObject, prettyPrinted: false)
        mNote.content = contentJSON
        
        let activities = Session.getContexts("Activity")
        var selectedActivity = Context.getContextByName("Bird Counting", contexts: activities)
        mNote.context = selectedActivity
        
        
        mNote.created_at = createdAt
        mNote.modified_at = createdAt
        
        // save to Media
        self.noteMedia = mNote.doSaveMedia(self.previewImageview.image!, timestamp: timestamp)
        
        // save to Feedback
        let landmarkCell = self.tableview.cellForRowAtIndexPath(locationCellIndexPath)
        
        if let landmark = landmarkCell!.detailTextLabel?.text {
            var selectedLandmark = Context.getContextByName(landmark, contexts: landmarks)
            self.feedback = mNote.doSaveFeedback(selectedLandmark, timestamp: timestamp)
        }
        
        mNote.commit()
        self.note = mNote
    }
    
    private func JSONStringify(value: AnyObject, prettyPrinted: Bool = false) -> String {
        var options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : nil
        if NSJSONSerialization.isValidJSONObject(value) {
            if let data = NSJSONSerialization.dataWithJSONObject(value, options: options, error: nil) {
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            }
        }
        return ""
    }
    
    // a new way, always choose the closest location as long as the locaiton is in the park
    private func determineLandmarkByLocation(userLocaiton: CLLocation) -> String {
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
    
    
}