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
    
    func parseFeedbackJSON(feedback: NSDictionary) {
        self.uid = feedback["id"] as Int
        self.content = feedback["content"] as String
        self.kind = feedback["kind"] as String
        self.modified_at = feedback["modified_at"] as Int
        self.created_at = feedback["created_at"] as Int
        self.state = STATE.DOWNLOADED
    }

    func toString() -> String {
        return "note feedback id: \(uid) content: \(content) note_id: \(note.uid)"
    }
}
