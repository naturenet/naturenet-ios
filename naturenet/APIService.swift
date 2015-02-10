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

    func post(params : Dictionary<String, Any>, url: String) {
        var request = NSMutableURLRequest(URL: NSURL(string: url)!)
        var session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        println("params is \(params)")
        var httpBody = paramsToHttpBody(params)
        println("httpbody is \(httpBody)")
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        var err: NSError?
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        var task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            println("Response: \(response)")
            var strData = NSString(data: data, encoding: NSUTF8StringEncoding)
            println("Body: \(strData)")
            var err: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: .MutableLeaves, error: &err) as? NSDictionary
            
            // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
            if(err != nil) {
                println(err!.localizedDescription)
                let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                println("Error could not parse JSON: '\(jsonStr)'")
            }
            else {
                // The JSONObjectWithData constructor didn't return an error. But, we should still
                // check and make sure that json has a value using optional binding.
                if let parseJSON = json {
                    // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                    var success = parseJSON["status_code"] as? Int
                    println("Succes: \(success)")
                }
                else {
                    // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                    let jsonStr = NSString(data: data, encoding: NSUTF8StringEncoding)
                    println("Error could not parse JSON: \(jsonStr)")
                }
            }
        })
        
        task.resume()
    }
   
    func paramsToHttpBody(params: Dictionary<String, Any>) -> String {
        var paramBody: String = String()
        for (key, value) in params {
            paramBody += "\(key)=\(value)&"
        }
        return paramBody.substringToIndex(paramBody.endIndex.predecessor())
    }
    
    
}