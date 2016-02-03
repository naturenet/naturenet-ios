//
//  NoteActivitySelectionViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/4/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class NoteActivitySelectionViewController: UIViewController, UITableViewDelegate {

    var activities: [Context]!
    var selectedActivityTitle: String!
    
    @IBOutlet weak var activitySelectionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
   func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("activitySelectionCell", forIndexPath: indexPath) 
        let activity = self.activities[indexPath.row] as Context
        cell.textLabel?.text = activity.title
        
        if activity.title == selectedActivityTitle {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let selectedIndex = getActivityIndex(selectedActivityTitle)
        //Other row is selected - need to deselect it
        let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: selectedIndex, inSection: 0))
        cell?.accessoryType = .None
        selectedActivityTitle = activities[indexPath.row].title
        
        //update the checkmark for the current row
        let newcell = activitySelectionTableView.cellForRowAtIndexPath(indexPath)
        newcell?.accessoryType = .Checkmark
    }
    
    func getActivityIndex(selectedActivityTitle: String) -> Int {
        var index = 0
        for activity in activities {
            if activity.title == selectedActivityTitle {
                break
            }
            index++
        }
        return index
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passedActivitySelection" {
            let cell = sender as! UITableViewCell
            let indexPath = activitySelectionTableView.indexPathForCell(cell)
            selectedActivityTitle = activities[indexPath!.row].title
        }
    }

}
