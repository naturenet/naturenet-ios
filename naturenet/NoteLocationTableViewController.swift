//
//  NoteLocationTableViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/5/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class NoteLocationTableViewController: UITableViewController {
    
    // data
    var landmarks: [Context]!
    var selectedLocation: String!
    
    // UI IBOutlets
    @IBOutlet var locationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return landmarks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("locationSelectionCell", forIndexPath: indexPath) as UITableViewCell
        var activity = self.landmarks[indexPath.row] as Context
        cell.textLabel?.text = activity.title
        if activity.title == selectedLocation {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        var selectedIndex = getLandmarkIndex(selectedLocation)
        //Other row is selected - need to deselect it
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0))
        cell?.accessoryType = .None
        selectedLocation = landmarks[indexPath.row].title
        //update the checkmark for the current row
        let newcell = locationsTableView.cellForRowAtIndexPath(indexPath)
        newcell?.accessoryType = .Checkmark
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passedLocationSelection" {
            let cell = sender as UITableViewCell
            let indexPath = locationsTableView.indexPathForCell(cell)
            selectedLocation = landmarks[indexPath!.row].title
            println("selected loc \(selectedLocation)")

        }
    }

    func getLandmarkIndex(selectedLocation: String) -> Int {
        var index = 0
        for landmark in landmarks {
            if landmark.title == selectedLocation {
                break
            }
            index++
        }
        return index
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
