//
//  ActivityDetailViewController.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/15/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController {
    
    var activity: Context!

    @IBOutlet weak var activityNavItem: UINavigationItem!
    @IBOutlet weak var activityIconImageView: UIImageView!
    @IBOutlet weak var activityDescriptionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView() {
        var iconURL = activity.extras
        loadImageFromWeb(iconURL, imageView: activityIconImageView)
        activityNavItem.title = activity.title
        activityDescriptionTextView.text = activity.context_description
    }
    
    private func loadImageFromWeb(iconURL: String, imageView: UIImageView) {
        var url = NSURL(string: iconURL)
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
            } else {
                let image = UIImage(data: data)
                imageView.image = image
            }
        })
    }
}
