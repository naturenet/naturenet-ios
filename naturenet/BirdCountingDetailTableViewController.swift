//
//  BirdCountingDetailTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/8/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class BirdCountingDetailTableViewController: UITableViewController, UIPickerViewDelegate,
                    UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var numberPickerView: UIPickerView!
    @IBOutlet weak var numberTextLable: UILabel!
    @IBOutlet weak var detailTextField: UITextField!
    
    // cells
    var numberPickerIsShowing = false
    let numberPickerCellIndexPathRow = 1
    let numberPickerCellIndexPathSection = 1
    let detailCellIndexPath = NSIndexPath(forRow: 0, inSection: 2)
    let locationCellIndexPath = NSIndexPath(forRow: 2, inSection: 2)
    

    // data
    let pickerData = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "10+"]
    var landmarks: [Context] = Session.getLandmarks()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButton()
        hideNumberPickerCell()
//        signUpForKeyboardNotifications()
//        self.detailTextField.delegate = self
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
        addPhotoBtn.addTarget(self, action: "addPhotoButtonPressed", forControlEvents: .TouchUpInside)
    }
    
    func addPhotoButtonPressed() {
        println("add your photo here")
        
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
//        self.cameraImage = info[UIImagePickerControllerOriginalImage] as? UIImage
//        self.performSegueWithIdentifier("tourToObservationDetail", sender: self)
    }
    
    //----------------------------------------------------------------------------------------------------------------------
    // keyboard events
    //----------------------------------------------------------------------------------------------------------------------

    func signUpForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func keyboardWillShow() {
        if self.numberPickerIsShowing {
            self.hideNumberPickerCell()
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.detailTextField.resignFirstResponder()
        return false
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // IBActions for unwind segues
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
