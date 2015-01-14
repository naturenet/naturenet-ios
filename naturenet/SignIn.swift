//
//  SignIn.swift
//  nn
//
//  Created by Jinyue Xia on 1/1/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit
import CoreData

class SignIn: UIViewController {
    @IBOutlet weak var textFieldUname: UITextField!
    @IBOutlet weak var textFieldUpass: UITextField!
    
    @IBAction func textFieldDoneEditing(sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTap(sender: UIControl) {
        textFieldUname.resignFirstResponder()
        textFieldUpass.resignFirstResponder()
    }
    
    @IBAction func btnSignIn() {
        println("sign in clicked")
//        var user = User()
//        user.doPullByName("car")
        let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var user = Account()
        user.doPullByName("car")
//        NNModel.resolveByName(appDelegate, name: "car")
    }
    
}
