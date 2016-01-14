//
//  Feedback.swift
//  naturenet
//
//  Created by Jinyue Xia on 2/4/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData

@objc(Feedback)
class Feedback: NNModel {

    @NSManaged var account_id: NSNumber
    @NSManaged var content: String
    @NSManaged var kind: String
    @NSManaged var target_id: NSNumber
    @NSManaged var target_model: String
    @NSManaged var note: Note
    @NSManaged var account: Account
    
    func parseFeedbackJSON(feedback: NSDictionary) {
        self.uid = feedback["id"] as! Int
        self.content = feedback["content"] as! String
        self.kind = feedback["kind"] as! String
        self.modified_at = feedback["modified_at"] as! NSNumber
        self.created_at = feedback["created_at"] as! NSNumber
        let accountID = feedback["account"]!["id"] as! Int
        self.account_id = accountID
        let predicate = NSPredicate(format: "uid = \(accountID)")
        // the feedback can be other user's comment in "feedbacks"
        if let account = NNModel.fetechEntitySingle(NSStringFromClass(Account), predicate: predicate) as? Account {
            self.account = account
        }
        self.state = STATE.DOWNLOADED
    }
    
    func save() {
        
    }
    
    override func doPushNew(apiService: APIService) {
        let posturl = APIAdapter.api.getCreateFeedbackLink(self.kind, model: self.target_model, uid: self.note.uid.integerValue, userName: self.account.username)
//        println{"request feedback link is: \(posturl)"}
        let params = ["content": self.content] as Dictionary<String, Any>
        apiService.post(NSStringFromClass(Feedback), sourceData: self, params: params, url: posturl)
    }
    
    override func doPushUpdate(apiService: APIService) {
        let posturl = APIAdapter.api.getUpdateFeedbackLink(self.uid.integerValue)
        //        println{"request feedback link is: \(posturl)"}
        let params = ["content": self.content, "username": self.account.username] as Dictionary<String, Any>
        apiService.post(NSStringFromClass(Feedback), sourceData: self, params: params, url: posturl)
    }

    func toString() -> String {
        return "note feedback id: \(uid) note_id: \(note.uid)"
    }
}
