//
//  NoteDescriptionViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/4/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class NoteDescriptionViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var noteDescriptionTextView: UITextView!
    @IBOutlet weak var barItemDone: UIBarButtonItem!
 
    var noteContent: String?

    override func viewDidLoad() {
        super.viewDidLoad()
//        UIBarButtonItem.appearance().setTitleTextAttributes({NSForegroundColorAttributeName: UIColor.blueColor()}, forState: .Disabled)
        noteDescriptionTextView.text = noteContent
        noteDescriptionTextView.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidChange(textView: UITextView) { //Handle the text changes here
        noteContent = noteDescriptionTextView.text
    }
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "passedDescription" {
            noteContent = noteDescriptionTextView.text
        }
    }
    

    
}
