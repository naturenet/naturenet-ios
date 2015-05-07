//
//  BirdActivityTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/22/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class BirdActivityTableViewController: UITableViewController, UIPickerViewDelegate, APIControllerProtocol {

    @IBOutlet var tableview: UITableView!
    
    // data
    var birds: [BirdCount] = [BirdCount] ()
    var activity: Context!
    var activityThumbURL: String!
    var activityDescription: String!
    var pickerData: [String] = [String]()
    var noteDescription: String?
    
    // constant numbers of fixed sections
    let NUMOFFIXEDSECTIONS = 2
    let DESCRIPTIONSECTION = 0
    let NOTESECTION = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...20 {
            pickerData.append(String(i))
        }
//        self.tableview.tableHeaderView = UIView(frame: CGRectMake(0, 0, self.tableview.bounds.size.width, 0.1))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func viewDidLayoutSubviews() {
//        // reserved for a "sent" status
//        tableview.headerViewForSection(1)?.textLabel.textAlignment = NSTextAlignment.Right
//    }
    
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
        if indexPath.section > 0 && indexPath.section < tableView.numberOfSections() - 1 {
            height = 135.0
        }

        return height
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        if indexPath.section == 0 {
            height = 100
        }
        return height
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var header: String?
        if section > 0 && section < tableView.numberOfSections() - 1 {
            header = birds[section-1].name
        }
        if section == 0 {
            header = "About this acitivty"
        }

        return header
        
    }
    
//    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        var footer: String?
//        if section > 0 && section < tableView.numberOfSections() - 1 {
//            footer = "Daily average this season: 20"
//        }
//
//        return footer
//    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var label: UILabel?
        
        if section > 0 && section < tableView.numberOfSections() - 1 {
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
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section > 0 && indexPath.section < tableView.numberOfSections() - 1 {
            let cellNib = UINib(nibName: "BirdActivityTableViewCell", bundle: NSBundle.mainBundle())
            tableView.registerNib(cellNib, forCellReuseIdentifier: "BirdActivityTableViewCell")
            let cell = tableView.dequeueReusableCellWithIdentifier("BirdActivityTableViewCell", forIndexPath: indexPath) as! BirdActivityTableViewCell
            cell.loadingIndicator.startAnimating()
            cell.loadingIndicator.color = UIColor.blueColor()
            if birds.count > 0 {
                loadImageFromWeb(birds[indexPath.section - 1].thumbnailURL, imageview: cell.previewImageView, indicatorView: cell.loadingIndicator)
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
            
            if indexPath.section == 0 {
                // cell!.textLabel?.numberOfLines = 8
                cell!.textLabel?.numberOfLines = 0
                cell!.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
                cell!.textLabel?.text = activityDescription
                cell?.selectionStyle = UITableViewCellSelectionStyle.None
            }
            
//            if indexPath.section == tableView.numberOfSections() - LASTTWOSECTIONS {
//                if indexPath.row == 0 {
//                    cell!.textLabel?.text = "You have seen"
//                    cell!.detailTextLabel?.text = "2"
//                }
//                if indexPath.row == 1 {
//                    cell!.textLabel?.text = "Total in Aces Since 2013"
//                    cell!.detailTextLabel?.text = "20"
//                }
//                cell?.selectionStyle = UITableViewCellSelectionStyle.None
//            }

            if indexPath.section == tableView.numberOfSections() - 1 {
                cell!.textLabel?.text = "Note"
                if let nDescription = self.noteDescription {
                    cell!.detailTextLabel?.text = self.noteDescription
                } else {
                    cell!.detailTextLabel?.text = ""
                }
                cell?.selectionStyle = UITableViewCellSelectionStyle.Default
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            return cell!

        }
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
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
    
    // implement didReceiveResults to conform APIControllerProtocol
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) -> Void {
        dispatch_async(dispatch_get_main_queue(), {
            var status = response["status_code"] as! Int
            if status == 600 {
                if let note = sourceData as? Note {
                    
                }
                let alertTitle = "Internet Connection Problem"
                let alertMessage = "Please check your Internet connection"
                AlertControllerHelper.createGeneralAlert(alertTitle, message: alertMessage, controller: self)
                return
            }
            
            if status == 200 {
                var uid = response["data"]!["id"] as! Int
                println("now after post_birdactivity. Done!")
                var modifiedAt = response["data"]!["modified_at"] as! NSNumber
                self.navigationItem.title = self.activity.title
                if let newNote = sourceData as? Note {
                    newNote.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                }
            }
            

        })
    }
    
    // receive data from note description textview
    @IBAction func passedDescription(segue:UIStoryboardSegue) {
        let noteDescriptionVC = segue.sourceViewController as! NoteDescriptionViewController
        let indexPath = NSIndexPath(forRow: 0, inSection: self.tableview.numberOfSections() - 1)
        let cell = self.tableview.cellForRowAtIndexPath(indexPath)!
        if let desc = noteDescriptionVC.noteContent {
            self.noteDescription = desc
            cell.detailTextLabel?.text = desc
        }
        self.navigationItem.rightBarButtonItem?.style = .Done
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendPressed(sender: UIBarButtonItem) {
        self.navigationItem.title = "Sending..."
        let note = saveNote()
        let apiService = APIService()
        apiService.delegate = self
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
        mNote.kind = "FieldNote"
        mNote.state = NNModel.STATE.NEW
        mNote.context = self.activity

        let noteIndexPath = NSIndexPath(forRow: 0, inSection: self.tableView.numberOfSections() - 1)
        let descriptionCell = self.tableView.cellForRowAtIndexPath(noteIndexPath) as UITableViewCell!
        var content = descriptionCell?.detailTextLabel?.text
        let birdJSONs = convertBirdCountToJSON(birds)
        let contentObject: [String : AnyObject] = ["type" : "bird", "birds" : birdJSONs, "description": content!]
        let contentJSON = self.JSONStringify(contentObject, prettyPrinted: true)
        println(contentJSON)
        mNote.content = contentJSON

        mNote.created_at = createdAt
        mNote.modified_at = createdAt
        mNote.commit()
        return mNote
    }
    
    func convertBirdCountToJSON(birds: [BirdCount]) -> [NSDictionary] {
        var section = 1
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
    
    private func JSONStringify(value: AnyObject, prettyPrinted: Bool = true) -> String {
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
        
        func toDictionary() -> [String: String] {
            return [
                "birdname": self.name,
                "birdcount": self.countNumber 
            ]
        }
        
    }


}
