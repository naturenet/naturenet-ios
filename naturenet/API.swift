//
//  API.swift
//  nn
//
//  Created by Jinyue Xia on 1/3/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation

class API {
    var root : String
    
    init() {
        self.root = "http://naturenet-dev.herokuapp.com/api/"
    }
    
    // get account api link
    func getAccountLink(userName : String) -> String {
        return root + "account/" + userName
    }
    
    // get account notes api link
    func getAccountNotesLink(userName : String) -> String {
        return root + "account/" + userName + "/notes"
    }
    
    
}