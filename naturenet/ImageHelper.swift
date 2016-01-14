//
//  ImageHelper.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/29/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import UIKit

class ImageHelper {
    
    class func createThumbCloudinaryLink(url: String, width: Int, height: Int) -> String {
        let urlArr = url.characters.split { $0 == "/" }.map { String($0) }
        var newURL = "http:"
        for str in urlArr {
            if str == "http:" {
                newURL += "/"
            } else {
                newURL += "/" + str
            }
            if str == "upload" {
                // newURL += "/w_600,h_600,c_fit"
                newURL += "/w_\(width),h_\(height),c_fit"
            }
        }
        // println("new url is " + newURL)
        return newURL
    }
    
    class func loadImageFromWeb(iconURL: String, imageview: UIImageView, indicatorView: UIActivityIndicatorView?) {
        var url = NSURL(string: iconURL)
        let urlRequest = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
            response, data, error in
            if error != nil {
                let image = UIImage(named: "networkerror")
                imageview.image = image
            } else {
                let image = UIImage(data: data!)
                imageview.image = image
            }
            if indicatorView != nil {
                indicatorView!.hidden = true
                indicatorView!.stopAnimating()
            }
        })
    }
}