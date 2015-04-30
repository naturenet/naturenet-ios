//
//  AlertControllerHelper.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/16/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import UIKit

class AlertControllerHelper {

    class func noLocationAlert(message: String, controller: UIViewController) {
        var alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        var okAction = UIAlertAction(title: "Settings", style: .Default, handler: { (action) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
            return
        })
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    // create an alert
    class func createGeneralAlert(alertTitle: String, message: String, controller: UIViewController) {
        var alert = UIAlertController(title: alertTitle, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            controller.dismissViewControllerAnimated(true, completion: nil)
        }))
        controller.presentViewController(alert, animated: true, completion: nil)
    }


}