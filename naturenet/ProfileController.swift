//
//  ProfileController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/2/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ProfileController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var profileTableView: UITableView!
    @IBOutlet weak var signoutBtn: UIButton!
    
    var titles = ["Name", "Observations", "Design Ideas"]
    var details = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let account = Session.getAccount() {
            details.append(account.username)
            var notes = account.getNotes()
            details.append(String(notes.count))
            details.append(String(notes.count))
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return details.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "profilecell")
        let cell = tableView.dequeueReusableCellWithIdentifier("profilecell", forIndexPath: indexPath) as ProfileTableViewCell
        cell.titleLabel!.text = titles[indexPath.row]
        cell.numberLabel!.text = String(details[indexPath.row])
        return cell
    }

    // returning to view
    override func viewWillAppear(animated: Bool) {
//        tblTasks.reloadData()
    }

    @IBAction func signout(sender: AnyObject) {
        Session.signOut()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
}
