//
//  BirdCountingTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/8/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

//
// Deprecated
//
class BirdCountingTableViewController: UITableViewController, UICollectionViewDelegate, SaveObservationProtocol, UIPickerViewDelegate {
    
    // UI
    @IBOutlet weak var birdsCollectionView: UICollectionView!
    @IBOutlet weak var numberPickerView: UIPickerView!
    @IBOutlet weak var birdActivityImageView: UIImageView!
    @IBOutlet weak var birdActivityDescriptionLabel: UILabel!
    @IBOutlet var tableview: UITableView!
    
    // data
    var activity: Context!
    var activityThumbURL: String!
    var activityDescription: String!
    var birds: [BirdCount] = [BirdCount]()
    let apiService = APIService()
    var numberPickerIsShowing = false

    
    // tableview data
    var items = ["Black-billed Magpie", "Pine Siskin", "Stellers Jay", "Red-breasted", "Mallard", "American Goldfinch"]
    var images = ["nnObservations", "nnActivities", "nnDesign", "nnAces", "nnProfile", "nnAbout"]
    let pickerData = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "10+"]

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        hideNumberPickerCell()
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // collectionView
    //----------------------------------------------------------------------------------------------------------------------
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // The cell that is returned must be retrieved from a call to dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("birdcell", forIndexPath: indexPath) as! BirdCountingCollectionViewCell
        // cell.backgroundColor = (indexPath.row % 2 == 0) ? UIColor.whiteColor() : UIColor.lightGrayColor()
        cell.loadingIndicator.hidden = false
        cell.loadingIndicator.startAnimating()
        loadImageFromWeb(birds[indexPath.row].thumbnailURL, imageview: cell.imageView, indicatorView: cell.loadingIndicator)
        cell.label.text = birds[indexPath.row].name
        return cell
    }
    
    // programmatically set the cell's size
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!,
        sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
            let viewSize = collectionView.bounds
            let cellWidth = viewSize.width/3 - 10
            let cellHeight = viewSize.height/2 - 10
            return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    // implement UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.birdsCollectionView.cellForItemAtIndexPath(indexPath) as! BirdCountingCollectionViewCell
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.blueColor().CGColor
        showNumberPickerCell()
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = self.birdsCollectionView.cellForItemAtIndexPath(indexPath) as! BirdCountingCollectionViewCell
        cell.layer.borderWidth = 0

    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if indexPath.section == 2 && indexPath.row == 0 {
//            self.performSegueWithIdentifier("birdcountingToObservations", sender: self)
//        }
        if indexPath.section == 0 || indexPath.section == 2 {
            self.hideNumberPickerCell()
        }
        
    }
    
    override func tableView(tableview: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var height = super.tableView(tableview, heightForRowAtIndexPath: indexPath)
        if indexPath.section == 1 {
            if indexPath.row == 1  {
                if !self.numberPickerIsShowing {
                    height = 0
                }
            }
        }
        return height
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
        let indexPathForPicker = NSIndexPath(forRow: 0, inSection: 0)
        let birdCell = self.birdsCollectionView.cellForItemAtIndexPath(indexPathForPicker) as! BirdCountingCollectionViewCell
        birdCell.numberLabel.text = pickerData[row]
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "birdCountingDetail" {
            let destViewController = segue.destinationViewController as! BirdCountingDetailTableViewController
            let cell = sender as! BirdCountingCollectionViewCell
            let indexPath = birdsCollectionView.indexPathForCell(cell)
            destViewController.navigationItem.title = items[indexPath!.row]
            destViewController.saveObservationDelegate = self
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
        }
        
    }
    
    func saveObservation(note: Note, media: Media?, feedback: Feedback?) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    private func initView() {
        loadImageFromWeb(activityThumbURL, imageview: self.birdActivityImageView, indicatorView: nil)
        self.birdActivityDescriptionLabel.text = self.activityDescription
        self.navigationController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "sendPressed")
    }
    
    func sendPressed() {
        println("bird send")
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

    
    class BirdCount {
        var name: String!
        var count: Int!
        var thumbnailURL: String!
    }


}
