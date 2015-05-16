//
//  BirdActivityTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/22/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreLocation

class BirdActivityTableViewController: UITableViewController, UIPickerViewDelegate, APIControllerProtocol, CLLocationManagerDelegate {

    @IBOutlet var tableview: UITableView!
    
    // data
    var birds: [BirdCount] = [BirdCount] ()
    var activity: Context!
    var activityThumbURL: String!
    var activityDescription: String!
    var pickerData: [String] = [String]()
    var noteDescription: String?
    var isDescriptionExpanded = false
    let apiService = APIService()
    
    let locationManager = CLLocationManager()
    
    // data for this page
    var userLat: CLLocationDegrees?
    var userLon: CLLocationDegrees?
    
    // constant numbers of fixed sections
    let NUMOFFIXEDSECTIONS = 3
    let ICONSECTION = 0
    let DESCRIPTIONSECTION = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...20 {
            pickerData.append(String(i))
        }
        self.navigationItem.rightBarButtonItem?.enabled = false

        apiService.delegate = self
        if let account = Session.getAccount() {
            let username = account.username
            let activityName = activity.name
            let api = API()
            let url = api.getBirdCountLink(username, birdActivityName: activityName)
            apiService.getResponse(NSStringFromClass(BirdActivityTableViewController), url: url)
        }
        
        initLocationManager()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

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
        // 2 is fixed for last two sections plus first section
        return birds.count + NUMOFFIXEDSECTIONS
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rows: Int = 1
        return rows
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        if indexPath.section == ICONSECTION {
            height = 60.0
        }
        if indexPath.section > DESCRIPTIONSECTION && indexPath.section < tableView.numberOfSections() - 1 {
            height = 140.0
        }

        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        if indexPath.section == DESCRIPTIONSECTION {
            height = 300
        }
        return height
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header: String?
        if section > DESCRIPTIONSECTION && section < tableView.numberOfSections() - 1 {
            var birdIndex = section - DESCRIPTIONSECTION - 1
            header = birds[birdIndex].name
        }
        if section == DESCRIPTIONSECTION {
            header = "About this acitivty"
        }

        return header
        
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footer: String?
        if section > DESCRIPTIONSECTION && section < tableView.numberOfSections() - 1 {
            footer = "Daily average this season: " + "--"
        }

        return footer
    }
   
    /*
     * reserverd for placing the footer right
    //
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var label: UILabel?
        
        if section > DESCRIPTIONSECTION && section < tableView.numberOfSections() - 1 {
            var footer = "Daily average this season: 20  "
            label = UILabel()
            label!.text = footer
            label!.textColor = UIColor.grayColor()
            label!.font = UIFont.systemFontOfSize(16)
            label!.textAlignment = NSTextAlignment.Right
        
        }
        
        return label
        
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    */
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == ICONSECTION {
            // "activityImageCell" is defined in ActivitesTableViewController scence
            let cellNib = UINib(nibName: "ActivityIconTableViewCell", bundle: NSBundle.mainBundle())
            tableView.registerNib(cellNib, forCellReuseIdentifier: "ActivityIconTableViewCell")
            let cell = tableView.dequeueReusableCellWithIdentifier("ActivityIconTableViewCell", forIndexPath: indexPath) as! ActivityIconTableViewCell
            ImageHelper.loadImageFromWeb(self.activityThumbURL, imageview: cell.activityIconImageView, indicatorView: cell.activityIndicator)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        
        if indexPath.section > DESCRIPTIONSECTION && indexPath.section < tableView.numberOfSections() - 1 {
            let cellNib = UINib(nibName: "BirdActivityTableViewCell", bundle: NSBundle.mainBundle())
            tableView.registerNib(cellNib, forCellReuseIdentifier: "BirdActivityTableViewCell")
            let cell = tableView.dequeueReusableCellWithIdentifier("BirdActivityTableViewCell", forIndexPath: indexPath) as! BirdActivityTableViewCell
            cell.loadingIndicator.startAnimating()
            cell.loadingIndicator.color = UIColor.blueColor()
            if birds.count > 0 {
                var birdIndex = indexPath.section - DESCRIPTIONSECTION - 1
                loadImageFromWeb(birds[birdIndex].thumbnailURL, imageview: cell.previewImageView, indicatorView: cell.loadingIndicator)
                cell.birdNameLabel.text = "Today"
            }
            let numberPickerViewer = cell.numberPickerView
            numberPickerViewer.delegate = self
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("BirdActivityRegularCell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "BirdActivityRegularCell") as UITableViewCell
            }
            
            if indexPath.section == DESCRIPTIONSECTION {
                cell!.textLabel?.numberOfLines = 2
                cell!.textLabel?.text = activityDescription
                // cell?.selectionStyle = UITableViewCellSelectionStyle.None

            }
            if indexPath.section == tableView.numberOfSections() - 1 {
                cell!.textLabel?.text = "Note"
                if let nDescription = self.noteDescription {
                    cell!.detailTextLabel?.text = self.noteDescription
                } else {
                    cell!.detailTextLabel?.text = " "
                }
                cell?.selectionStyle = UITableViewCellSelectionStyle.Default
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            return cell!
        }
        
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == DESCRIPTIONSECTION {
            let cell = self.tableview.cellForRowAtIndexPath(indexPath)
            if isDescriptionExpanded {
                cell!.textLabel?.numberOfLines = 2
                isDescriptionExpanded = false
            } else {
                cell!.textLabel?.numberOfLines = 0
                cell!.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell!.textLabel?.text = activityDescription
                isDescriptionExpanded = true
            }
            self.tableview.beginUpdates()
            self.tableview.endUpdates()
        }


        if indexPath.section == tableView.numberOfSections() - 1 {
            let nextViewController: NoteDescriptionViewController = self.storyboard?.instantiateViewControllerWithIdentifier("NoteDescriptionViewController")
                as! NoteDescriptionViewController
            let cell = self.tableview.cellForRowAtIndexPath(indexPath)!
            if  let noteDescription = cell.detailTextLabel?.text {
                if count(noteDescription) > 0 {
                    nextViewController.noteContent = cell.detailTextLabel?.text
                }
            }
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    private func loadImageFromWeb(iconURL: String, imageview: UIImageView, indicatorView: UIActivityIndicatorView?) {
        var url = NSURL(string: iconURL)
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
                let image = UIImage(named: "networkerror")
                imageview.image = image
            } else {
                let image = UIImage(data: data)
                imageview.image = image
            }
            
            if indicatorView != nil {
                indicatorView!.hidden = true
                indicatorView!.stopAnimating()
            }
        })
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
        self.locationManager.stopUpdatingLocation()
    }
    
    // implement location didFailWithError
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        // println("error happened locationmanager \(error.domain)")
        var message = "NatureNet requires to acess your location"
        AlertControllerHelper.noLocationAlert(message, controller: self)
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
  
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let frame = pickerView.bounds
        let pickerLabel = UILabel(frame: CGRectInset(frame, 15, 0))
        let titleData = pickerData[row]
        pickerLabel.text = titleData
        pickerLabel.font = UIFont.systemFontOfSize(18)
        pickerLabel.textColor = UIColor.blueColor()
        return pickerLabel
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.navigationItem.rightBarButtonItem?.title = "Send"

    }
    
    // implement didReceiveResults to conform APIControllerProtocol
    // get response from APIs
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as! Int
            if status == APIService.CRASHERROR {
                let alertTitle = "Internet Connection Problem"
                let alertMessage = "Please check your Internet connection"
                AlertControllerHelper.createGeneralAlert(alertTitle, message: alertMessage, controller: self)
                return
            }
            
            if status == 200 {
                if from == "POST_" + NSStringFromClass(Note) {
                    var uid = response["data"]!["id"] as! Int
                    println("now after post_birdactivity. Done!")
                    var modifiedAt = response["data"]!["modified_at"] as! NSNumber
                    self.navigationItem.title = self.activity.title
                    if let newNote = sourceData as? Note {
                        newNote.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                    }
                    
                    self.navigationItem.rightBarButtonItem?.title = "Sent"
                    self.navigationItem.rightBarButtonItem?.enabled = false
                } else  {
                    if let data = response["data"] as? NSDictionary {
                        if let birds = data["birds"] as? NSArray {
                            for bird in birds {
                                var birdname = bird["name"] as! String
                                for b in self.birds {
                                    if birdname == b.name {
                                        b.countNumber = bird["count"] as! String
                                        b.seasonalCount = bird["seasonal_count"] as? Int
                                    }
                                }
                            }
                            self.noteDescription = data["description"] as? String
                            self.updateStats()
                        }
                    }
                }
            }
        })
    }
    
    
    // update status
    private func updateStats() {
        var section = DESCRIPTIONSECTION + 1
        for bird in birds {
            var indexPath = NSIndexPath(forRow: 0, inSection: section)
            if let cell = self.tableview.cellForRowAtIndexPath(indexPath) as? BirdActivityTableViewCell {
                var pickerview = cell.numberPickerView
                pickerview.selectRow(bird.countNumber.toInt()!, inComponent: 0, animated: true)
            }
            if bird.seasonalCount != nil {
                self.tableView.footerViewForSection(section)?.textLabel.text = "Daily average this season: " + String(bird.seasonalCount!)
            }
            section++
        }
        let descIndexPath = NSIndexPath(forRow: 0, inSection: self.tableView.numberOfSections() - 1)
        if let cell = self.tableview.cellForRowAtIndexPath(descIndexPath) {
            cell.detailTextLabel?.text = self.noteDescription
        }
        
    }
    
    // receive data from note description textview
    @IBAction func passedDescription(segue:UIStoryboardSegue) {
        self.navigationItem.rightBarButtonItem?.style = .Done
        self.navigationController?.popViewControllerAnimated(true)
        let noteDescriptionVC = segue.sourceViewController as! NoteDescriptionViewController
        let indexPath = NSIndexPath(forRow: 0, inSection: self.tableview.numberOfSections() - 1)
        let cell = self.tableview.cellForRowAtIndexPath(indexPath)!
        if let desc = noteDescriptionVC.noteContent {
            self.noteDescription = desc
            cell.detailTextLabel?.text = desc
        }
    }
    
    @IBAction func sendPressed(sender: UIBarButtonItem) {
        self.navigationItem.title = "Sending..."
        let note = saveNote()
        note.push(apiService)
    }
    
    
    // save note
    private func saveNote() -> Note  {
        var timestamp = UInt64(floor(NSDate().timeIntervalSince1970 * 1000))
        var createdAt = NSNumber(unsignedLongLong: timestamp)
        
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var mNote = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as! Note
        
        var account = Session.getAccount()
        mNote.account = account!
        mNote.kind = "BirdCounting"
        mNote.state = NNModel.STATE.NEW
        mNote.context = self.activity

        if userLon != nil && userLat != nil {
            mNote.longitude = self.userLon!
            mNote.latitude = self.userLat!
        }
        
        let noteIndexPath = NSIndexPath(forRow: 0, inSection: self.tableView.numberOfSections() - 1)
        let descriptionCell = self.tableView.cellForRowAtIndexPath(noteIndexPath) as UITableViewCell!
        let birdJSONs = convertBirdCountToJSON(birds)
        
        var contentObject: [String : AnyObject] = ["type" : "bird", "birds" : birdJSONs, "description": ""]

        if var content = descriptionCell?.detailTextLabel?.text {
            contentObject = ["type" : "bird", "birds" : birdJSONs, "description": content]
        }
        let contentJSON = self.JSONStringify(contentObject, prettyPrinted: false)
        println(contentJSON)
        mNote.content = contentJSON

        mNote.created_at = createdAt
        mNote.modified_at = createdAt
        mNote.commit()
        return mNote
    }
    
    func convertBirdCountToJSON(birds: [BirdCount]) -> [NSDictionary] {
        var section = DESCRIPTIONSECTION + 1
        var birdJSONs = [NSDictionary]()
        for bird in birds {
            var indexPath = NSIndexPath(forRow: 0, inSection: section)
            if let  cell = self.tableview.cellForRowAtIndexPath(indexPath) as? BirdActivityTableViewCell {
                var pickerview = cell.numberPickerView
                bird.countNumber = self.pickerData[pickerview.selectedRowInComponent(0)]
                birdJSONs.append(bird.toDictionary())
            }
            section++
        }
        return birdJSONs
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


    // For bird count object
    class BirdCount {
        var name: String!
        var countNumber: String!
        var thumbnailURL: String!
        var seasonalCount: Int?
        
        func toDictionary() -> [String: String] {
            return [
                "name": self.name,
                "count": self.countNumber 
            ]
        }
        
    }


}
