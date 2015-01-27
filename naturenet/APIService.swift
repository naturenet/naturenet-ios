//
//  APIService.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/3/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation

protocol APIControllerProtocol {
    func didReceiveResults(from: String, response: NSDictionary) -> Void
}

class APIService {
    var delegate: APIControllerProtocol?
    
    init() {
    }
    
    func getResponse(from: String, url: String) {
        // request(settings.getAccountNotesLink(name), callback)
        request(from, url: url)

    }
    
    func request(from: String, url: String) {
        var nsURL = NSURL(string: url)
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsURL!, completionHandler: {
            (data, response, error) in
            var error: NSError?
            if error != nil {
                println(error!)
            } else {
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
                self.delegate?.didReceiveResults(from, response: jsonResult)
            }
        })
        
        task.resume()
    }
}