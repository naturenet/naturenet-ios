//
//  APIService.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/3/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import UIKit

protocol APIControllerProtocol {
    func didReceiveResults(from: String, sourceData: NNModel?, response: NSDictionary) -> Void
}

class APIService {
    var delegate: APIControllerProtocol?
    static let CRASHERROR = 600
    
    init() {
    }
    
    func getResponse(from: String, url: String) {
        // request(settings.getAccountNotesLink(name), callback)
        request(from, url: url)
    }
    
    func request(from: String, url: String) {
        let nsURL = NSURL(string: url)
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let task = NSURLSession.sharedSession().dataTaskWithURL(nsURL!, completionHandler: {
            (data, response, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error != nil {
                print(error!)
                let erorrMessage = ["status_code" : APIService.CRASHERROR]
                self.delegate?.didReceiveResults(from, sourceData: nil, response: erorrMessage)
            } else {
                do
                {
                    let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
                    if (jsonResult != nil)  {
                        self.delegate?.didReceiveResults(from, sourceData: nil, response: jsonResult!)

                    } else {
                        let message = ["status_code" : APIService.CRASHERROR]
                        self.delegate?.didReceiveResults(from,sourceData: nil, response: message)
                    }
                }
                catch { }
            }
        })
        
        task.resume()
    }

    // send a http post request
    func post(from: String, sourceData: NNModel?, params : Dictionary<String, Any>, url: String) {
        let source: String = "POST_" + from
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let httpBody = paramsToHttpBody(params)
        request.HTTPBody = httpBody.dataUsingEncoding(NSUTF8StringEncoding)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            // println("Body: \(strData)")
            do {
            
                let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableLeaves) as? NSDictionary
                
                // Did the JSONObjectWithData constructor return an error? If so, log the error to the console
                if(error != nil) {
                    print(error!.localizedDescription)
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                    let erorrMessage = ["status_code" : APIService.CRASHERROR]
                    self.delegate?.didReceiveResults(source, sourceData: sourceData, response: erorrMessage)
                }
                else {
                    // The JSONObjectWithData constructor didn't return an error. But, we should still
                    // check and make sure that json has a value using optional binding.
                    if let parseJSON = json {
                        // Okay, the parsedJSON is here, let's get the value for 'success' out of it
                        // let success = parseJSON["status_code"] as? Int
                        // println("Succes: \(success)")
                        self.delegate?.didReceiveResults(source, sourceData: sourceData, response: parseJSON)
                    }
                    else {
                        // Woa, okay the json object was nil, something went worng. Maybe the server isn't running?
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Error could not parse JSON: \(jsonStr)")
                        let erorrMessage = ["status_code" : APIService.CRASHERROR]
                        self.delegate?.didReceiveResults(source, sourceData: sourceData, response: erorrMessage)

                    }
                }
            }
            catch {}
        })
        
        task.resume()
    }
   
    // a general function to parse passed parameters to a HTTPPostBoby String
    func paramsToHttpBody(params: Dictionary<String, Any>) -> String {
        var paramBody: String = String()
        for (key, value) in params {
            paramBody += "\(key)=\(value)&"
        }
        return paramBody.substringToIndex(paramBody.endIndex.predecessor())
    }
    
    
}