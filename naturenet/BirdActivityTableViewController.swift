//
//  BirdActivityTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/22/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class BirdActivityTableViewController: UITableViewController, UIPickerViewDelegate {

    @IBOutlet var tableview: UITableView!
    
    // data
    var activity: Context!
    var activityThumbURL: String!
    var activityDescription: String!
    let apiService = APIService()
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 0...20 {
            pickerData.append(String(i))
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        tableview.footerViewForSection(0)?.textLabel.textAlignment = .Right
        
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

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        var rows: Int = 1
        if section == 1 {
            rows = 2
        }
        return rows
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        if indexPath.section == 0 {
            if indexPath.row == 0  {
                height = 150.0
            }
        }
        return height
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var footer: String?
        if section == 0 {
            footer = "Heron"
        }
        return footer
        
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        var footer: String?
        if section == 0 {
            footer = "Sent"
        }
        if section == 1 {
            footer = "Since April 2013"
        }
        return footer
    }
    
//    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == 0 {
//            
//            var statusLabel = UILabel()
//            statusLabel.text = "Send"
//            //        pickerLabel.font = UIFont.systemFontOfSize(20)
//            statusLabel.textColor = UIColor.blueColor()
//            statusLabel.textAlignment = .Right
//            return statusLabel
//        }
//        
//        return super.tableView.footerViewForSection(section)
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cellNib = UINib(nibName: "BirdActivityTableViewCell", bundle: NSBundle.mainBundle())
            tableView.registerNib(cellNib, forCellReuseIdentifier: "BirdActivityTableViewCell")
            let cell = tableView.dequeueReusableCellWithIdentifier("BirdActivityTableViewCell", forIndexPath: indexPath) as! BirdActivityTableViewCell
            cell.loadingIndicator.startAnimating()
            cell.loadingIndicator.color = UIColor.blueColor()
            loadImageFromWeb(activityThumbURL, imageview: cell.previewImageView, indicatorView: cell.loadingIndicator)
            let numberPickerViewer = cell.numberPickerView
            numberPickerViewer.delegate = self
            cell.setSelected(false, animated: true)
            return cell
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier("BirdActivityRegularCell") as? UITableViewCell

            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "BirdActivityRegularCell") as UITableViewCell
            }
            
            
            if indexPath.section == 1 {
                if indexPath.row == 0 {
                    cell!.textLabel?.text = "You have seen"
                    cell!.detailTextLabel?.text = "2"
                }
                if indexPath.row == 1 {
                    cell!.textLabel?.text = "Total in Aces"
                    cell!.detailTextLabel?.text = "20"
                }
            }
//            if indexPath.section == 2 {
//                cell!.textLabel?.text = "Total in Aces"
//                cell!.detailTextLabel?.text = "20"
//            }
            if indexPath.section == 2 {
                cell!.textLabel?.text = "Notes"
                cell!.detailTextLabel?.text = "note for the bird"
                cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            }
            
            return cell!

        }
        

    }
    
    private func loadImageFromWeb(iconURL: String, imageview: UIImageView, indicatorView: UIActivityIndicatorView?) {
        var url = NSURL(string: iconURL)
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
            } else {
                let image = UIImage(data: data)
                imageview.image = image
                if indicatorView != nil {
                    indicatorView!.hidden = true
                    indicatorView!.stopAnimating()
                }
                
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

    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPathForPicker = NSIndexPath(forRow: 0, inSection: 0)
//        let birdCell = self.birdsCollectionView.cellForItemAtIndexPath(indexPathForPicker) as! BirdCountingCollectionViewCell
//        birdCell.numberLabel.text = pickerData[row]
    }
  
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView!) -> UIView {
        let frame = pickerView.bounds
        let pickerLabel = UILabel(frame: CGRectInset(frame, 10, 0))
        let titleData = pickerData[row]
//        let myTitle = NSAttributedString(string: titleData, attributes: [ NSForegroundColorAttributeName:UIColor.blackColor()])
//        pickerLabel.attributedText = myTitle
        pickerLabel.text = titleData
        pickerLabel.font = UIFont.systemFontOfSize(20)
        pickerLabel.textColor = UIColor.blueColor()
        return pickerLabel
    }



}
