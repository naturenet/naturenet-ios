//
//  DesignIdeaViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/18/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class DesignIdeaViewController: UIViewController, APIControllerProtocol {

    @IBOutlet weak var ideaTextView: UITextView!
    
    var apiService = APIService()
    var idea: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiService.delegate = self
        // Do any additional setup after loading the view.
        setupTextview()
        ideaTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) {
        dispatch_async(dispatch_get_main_queue(), {
            if from == "POST_" + NSStringFromClass(Note) {
                var uid = response["data"]!["id"] as Int
                println("now after post_designIdea. Done!")
                var modifiedAt = response["data"]!["modified_at"] as NSNumber
                self.idea!.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
            }
            self.createAlert()
        })
    }
    
    
    @IBAction func backgroundTap(sender: UIControl) {
        ideaTextView.resignFirstResponder()
    }
    
    @IBAction func backpressed() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // when typing, change rightBarButtonItem style to be Done(bold)
    func textViewDidChange(textView: UITextView!) {
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.navigationItem.rightBarButtonItem?.style = .Done
        if countElements(self.ideaTextView.text) == 0 {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    // touch starts, dismiss keyboard
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.ideaTextView.resignFirstResponder()
    }
    
    @IBAction func ideaSendPressed(sender: UIBarButtonItem) {
        if countElements(self.ideaTextView.text) == 0 {
            // here should never be called
            self.createWarningAlert()
        } else {
            self.idea = saveIdea()
            self.idea!.push(apiService)
        }
    }
    
    func createAlert() {
        var alert = UIAlertController(title: "Your idea has been sent, thanks!", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
            action in
            if action.style == .Default{
                self.navigationController?.popViewControllerAnimated(true)
            }
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func createWarningAlert() {
        var alert = UIAlertController(title: "Oops", message: "You did not input any idea!", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // save to core data first
    func saveIdea() -> Note {
        var nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        var note = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as Note
        note.state = NNModel.STATE.NEW
        if let account = Session.getAccount() {
            note.account = account
        }
        
        if let site = Session.getSite() {
            var contexts = site.getContexts() as [Context]
            for context in contexts {
                if context.kind == "Design" {
                    note.context = context
                    break
                }
            }
        }
        note.kind = "DesignIdea"
        note.content = self.ideaTextView.text
        note.commit()
        SwiftCoreDataHelper.saveManagedObjectContext(nsManagedContext)
        return note
    }
    
    // initialize textview, add boarders to the textview
    func setupTextview() {
        ideaTextView.layer.cornerRadius = 5
        ideaTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        ideaTextView.layer.borderWidth = 1
    }

}
