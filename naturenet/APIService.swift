//
//  APIService.swift
//  nn
//
//  Created by Jinyue Xia on 1/3/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveResults(response: NSDictionary) -> Void
}

class APIService {
    var delegate: APIControllerProtocol?
    
    init() {
    }
    
    func getResponse(url: String) {
        // println("get API")
        // request(settings.getAccountNotesLink(name), callback)
        request(url)

    }
    
    func request(url: String) {
        var nsURL = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsURL!, completionHandler: {
            (data, response, error) in
            var error: NSError?
            if error != nil {
                println(error!)
            } else {
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
//                callback(jsonResult)
                self.delegate?.didReceiveResults(jsonResult)
            }
        })
        
        task.resume()
    }
}