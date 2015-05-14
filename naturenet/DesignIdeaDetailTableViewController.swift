//
//  DesignIdeaDetailTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 5/13/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreLocation

protocol SaveInputStateProtocol {
    func saveInputState(input: String?)
}

class DesignIdeaDetailTableViewController: UITableViewController, APIControllerProtocol, CLLocationManagerDelegate {

    var activity: Context!
    var apiService = APIService()
    
    var idea: Note?
    var designIdeaSavedInput: String?
    var delegate: SaveInputStateProtocol?
    
    let locationManager = CLLocationManager()
    // data for this page
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    
    // alert types
    let INTERNETPROBLEM = 0
    let SUCCESS = 1
    let NOINPUT = 2
    
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    @IBOutlet weak var iconActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var ideaTextView: UITextView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTextview()
        apiService.delegate = self
        self.initLocationManager()

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
                ImageHelper.loadImageFromWeb(iconURL, imageview: activityIconImageView, indicatorView: iconActivityIndicator)
            }
        }
        
        self.navigationItem.title = activity.title
        tableView.rowHeight = UITableViewAutomaticDimension
        activityDescriptionLabel.text = activity.context_description
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
        // println("location is  \(locations)")
        var userLocation: CLLocation = locations[0] as! CLLocation
        self.userLat = userLocation.coordinate.latitude
        self.userLon = userLocation.coordinate.longitude
    }
    
    // implement location didFailWithError
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // println("error happened locationmanager \(error.domain)")
        var message = "NatureNet requires to acess your location"
        AlertControllerHelper.noLocationAlert(message, controller: self)
    }

    
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) {
        dispatch_async(dispatch_get_main_queue(), {
            if from == "POST_" + NSStringFromClass(Note) {
                var status = response["status_code"] as! Int
                if status == APIService.CRASHERROR {
                    self.createAlert(nil, message: "Looks you have a problem with Internet connection!", type: self.INTERNETPROBLEM)
                    return
                }
                
                if status == 200 {
                    var uid = response["data"]!["id"] as! Int
                    println("now after post_designIdea. Done!")
                    var modifiedAt = response["data"]!["modified_at"] as! NSNumber
                    self.idea!.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                    self.designIdeaSavedInput = nil
                }
                
            }
            self.createAlert(nil, message: "Your idea has been sent, thanks!", type: self.SUCCESS)
        })
    }
    
    @IBAction func backpressed() {
        self.delegate?.saveInputState(designIdeaSavedInput)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // when typing, change rightBarButtonItem style to be Done(bold)
    func textViewDidChange(textView: UITextView!) {
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.navigationItem.rightBarButtonItem?.style = .Done
        if count(self.ideaTextView.text) == 0 {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        self.designIdeaSavedInput = textView.text
    }
    
    // touch starts, dismiss keyboard
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.ideaTextView.resignFirstResponder()
    }
    
    @IBAction func ideaSendPressed(sender: UIBarButtonItem) {
        if count(self.ideaTextView.text) == 0 {
            // here should never be called
            self.createAlert("Oops", message: "Your input is empty!", type: self.NOINPUT)
        } else {
            self.idea = saveIdea()
            self.idea!.push(apiService)
        }
    }
    
    func createAlert(title: String?, message: String, type: Int) {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
            action in
            if type == self.SUCCESS {
                if action.style == .Default{
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // save to core data first
    func saveIdea() -> Note {
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var note = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as! Note
        note.state = NNModel.STATE.NEW
        if let account = Session.getAccount() {
            note.account = account
        }
        
        if userLon != nil && userLat != nil {
            note.longitude = self.userLon!
            note.latitude = self.userLat!
        }
        
        note.context = activity

        note.kind = "DesignIdea"
        note.content = self.ideaTextView.text
        note.commit()
        SwiftCoreDataHelper.saveManagedObjectContext(nsManagedContext)
        return note
    }
    
    // initialize textview, add boarders to the textview
    func setupTextview() {
        ideaTextView.layer.cornerRadius = 5
        ideaTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        ideaTextView.layer.borderWidth = 1
        if designIdeaSavedInput != nil {
            ideaTextView.text = designIdeaSavedInput
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }

}
