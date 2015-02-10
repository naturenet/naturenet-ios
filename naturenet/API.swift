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
    
    // get site api link
    func getSiteLink(siteName: String) -> String {
        return root + "site/" + siteName + "/long"
    }
    
    // get createAccount api link
    func getCreateAccountLink() -> String {
        return root + "account/new/" 
    }
    
    // get createNote api link
    func getCreateNoteLink(username: String) -> String {
        return root + "note/new/" + username
    }
    
    // get updateNote api link
    func getUpdateNoteLink(uid: Int) -> String {
        return root + "note/\(uid)/update"
    }
    
    // get create media api link
    func getCreateMediaLink(uid: Int) -> String {
        return root + "note/\(uid)/new/photo"
    }
    
    // get create feedback api link
    func getCreateFeedbackLink(kind: String, model: String, uid: Int, userName: String) -> String {
        return root + "feedback/new/\(kind)/for/\(model)/\(uid)/by/\(userName)"
    }
}