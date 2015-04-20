//
//  ActivityDetailTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/19/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ActivityDetailTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var activity: Context!
    var cameraImage: UIImage!

    
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var activityDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        // self.edgesForExtendedLayout = UIRectEdge.None

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
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 3
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return 1
    }

    func setupView() {
        var iconURL = activity.extras
        loadImageFromWeb(iconURL, imageView: activityIconImageView)
        self.navigationItem.title = activity.title
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
        activityDescriptionLabel.text = activity.context_description
//        let descriptionCellIndexPath = NSIndexPath(forRow: 0, inSection: 1)
//        let descriptionCell = self.tableview.cellForRowAtIndexPath(descriptionCellIndexPath)!
//        descriptionCell.textLabel!.text = activity.context_description
    }
    
    private func loadImageFromWeb(iconURL: String, imageView: UIImageView) {
        var url = NSURL(string: iconURL)
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
            } else {
                let image = UIImage(data: data)
                imageView.image = image
            }
        })
    }

    //----------------------------------------------------------------------------------------------------------------------
    // segues setup
    //----------------------------------------------------------------------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "activityToObservation" {
            let detailVC = segue.destinationViewController as! ObservationDetailController
            //            detailVC.imageFromCamera = self.cameraImage!
            //            detailVC.imageFromObservation?.image = self.cameraImage!
            //            detailVC.imageFromObservation?.isFromGallery = false
            detailVC.imageFromObservation = ObservationsController.PickedImage(image: self.cameraImage, isFromGallery: false)
            detailVC.activityNameFromActivityDetail = activity.title
            detailVC.sourceViewController = NSStringFromClass(ActivityDetailViewController)
        }
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
        println("picker cancel.")
    }
    
    // after picking or taking a photo didFinishPickingMediaWithInfo
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        self.cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.performSegueWithIdentifier("activityToObservation", sender: self)
    }

    
 
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

}
