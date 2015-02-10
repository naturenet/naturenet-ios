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
        self.uid = feedback["id"] as Int
        self.content = feedback["content"] as String
        self.kind = feedback["kind"] as String
        self.modified_at = feedback["modified_at"] as Int
        self.created_at = feedback["created_at"] as Int
        var accountID = feedback["account"]!["id"] as Int
        self.account_id = accountID
        var account = NNModel.doPullByUIDFromCoreData(NSStringFromClass(Account), uid: accountID) as Account
        self.account = account
        self.state = STATE.DOWNLOADED
    }
    
    override func doPushNew(apiService: APIService) {
        var posturl = APIAdapter.api.getCreateFeedbackLink(self.kind, model: self.target_model, uid: self.note.uid.integerValue, userName: self.account.username)
//        println{"request feedback link is: \(posturl)"}
        var params = ["content": self.content] as Dictionary<String, Any>
        apiService.post(NSStringFromClass(Feedback), params: params, url: posturl)
    }

    func toString() -> String {
        return "note feedback id: \(uid) note_id: \(note.uid)"
    }
}
