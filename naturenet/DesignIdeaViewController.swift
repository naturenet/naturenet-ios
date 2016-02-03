//
//  DesignIdeaViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/18/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

/**
    Deprecated
    A new controller: DesignIdeaDetailTableViewController.swift
*/
class DesignIdeaViewController: UIViewController, APIControllerProtocol {

    @IBOutlet weak var ideaTextView: UITextView!
    
    var apiService = APIService()
    var idea: Note?
    var designIdeaSavedInput: String?
    var delegate: SaveInputStateProtocol?
    
    // alert types
    let INTERNETPROBLEM = 0
    let SUCCESS = 1
    let NOINPUT = 2
    
    
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
                let status = response["status_code"] as! Int
                if status == 600 {
                    self.createAlert(nil, message: "Looks you have a problem with Internet connection!", type: self.INTERNETPROBLEM)
                    return
                }
                
                if status == 200 {
                    let uid = response["data"]!["id"] as! Int
                    print("now after post_designIdea. Done!")
                    let modifiedAt = response["data"]!["modified_at"] as! NSNumber
                    self.idea!.updateAfterPost(uid, modifiedAtFromServer: modifiedAt)
                    self.designIdeaSavedInput = nil
                }

            }
            self.createAlert(nil, message: "Your idea has been sent, thanks!", type: self.SUCCESS)
        })
    }

    @IBAction func backpressed() {
        self.delegate?.saveInputState(designIdeaSavedInput)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    // when typing, change rightBarButtonItem style to be Done(bold)
    func textViewDidChange(textView: UITextView!) {
        self.navigationItem.rightBarButtonItem?.enabled = true
        self.navigationItem.rightBarButtonItem?.style = .Done
        if self.ideaTextView.text.characters.count == 0 {
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        self.designIdeaSavedInput = textView.text
    }
    
    // touch starts, dismiss keyboard
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.ideaTextView.resignFirstResponder()
    }
    
    @IBAction func ideaSendPressed(sender: UIBarButtonItem) {
        if self.ideaTextView.text.characters.count == 0 {
            // here should never be called
            self.createAlert("Oops", message: "Your input is empty!", type: self.NOINPUT)
        } else {
            self.idea = saveIdea()
            self.idea!.push(apiService)
        }
    }
    
    func createAlert(title: String?, message: String, type: Int) {
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {
                action in
                if type == self.SUCCESS {
                    if action.style == .Default{
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                }
            }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
        }
    }
    
    // save to core data first
    func saveIdea() -> Note {
        let nsManagedContext = SwiftCoreDataHelper.nsManagedObjectContext
        let note = SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: nsManagedContext) as! Note
        note.state = NNModel.STATE.NEW
        if let account = Session.getAccount() {
            note.account = account
        }
        
        if let site = Session.getSite() {
            let contexts = site.getContexts() as! [Context]
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
        if designIdeaSavedInput != nil {
            ideaTextView.text = designIdeaSavedInput
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }

}
