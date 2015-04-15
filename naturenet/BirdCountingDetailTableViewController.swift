//
//  BirdCountingDetailTableViewController.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/8/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class BirdCountingDetailTableViewController: UITableViewController, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var addPhotoBtn: UIButton!
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var numberPickerView: UIPickerView!
    @IBOutlet weak var numberTextLable: UILabel!
    @IBOutlet weak var detailTextField: UITextField!
    
    var numberPickerIsShowing = false
    let numberPickerCellIndexPathRow = 1
    let numberPickerCellIndexPathSection = 1

    let pickerData = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "10+"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeButton()
        hideNumberPickerCell()
        signUpForKeyboardNotifications()
        self.detailTextField.delegate = self
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
        //        self.addPhotoBtn.clipsToBounds = true
        addPhotoBtn.addTarget(self, action: "addPhotoButtonPressed", forControlEvents: .TouchUpInside)
    }
    
    func addPhotoButtonPressed() {
        println("add your photo here")
        
    }
    
    
    //----------------------------------------------------------------------------------------------------------------------
    // tableView
    //----------------------------------------------------------------------------------------------------------------------
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 2
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
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.detailTextField.resignFirstResponder()

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
