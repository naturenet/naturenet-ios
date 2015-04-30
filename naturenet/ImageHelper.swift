//
//  ImageHelper.swift
//  NatureNet
//
//  Created by Jinyue Xia on 4/29/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation

class ImageHelper {
    
    class func createThumbCloudinaryLink(url: String, width: Int, height: Int) -> String {
        var urlArr = split(url) { $0 == "/" }
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
}