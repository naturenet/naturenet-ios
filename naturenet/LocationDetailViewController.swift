//
//  LocationDetailViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/24/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class LocationDetailViewController: UIViewController {
    var locationTitle: String!
    var locationDescription: String!
    
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var navItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        navItem.title = locationTitle
        descriptionTextView.text = locationDescription
//        descriptionTextView.font.fontWithSize(20)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
