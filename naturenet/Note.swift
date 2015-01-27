//
//  Note.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/27/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData

@objc(Note)
class Note: NNModel {

    @NSManaged var status: String
    @NSManaged var longitude: NSNumber
    @NSManaged var latitude: NSNumber
    @NSManaged var kind: String
    @NSManaged var context_id: NSNumber
    @NSManaged var account_id: NSNumber
    @NSManaged var content: String
    
    // parse a note JSON
    func parseNoteJSON(mNote: NSDictionary) -> Note {
        self.uid = mNote["id"] as Int
        self.created_at = mNote["created_at"] as Int
        self.kind = mNote["kind"] as String
        self.modified_at = mNote["modified_at"] as Int
        if let lat = mNote["latitude"] as? Float {
            self.latitude = lat
        } else {
            self.latitude = 0.0
            println("no latitude")
        }
        
        if let lon = mNote["longitude"] as? Float {
            self.longitude = lon
        } else {
            self.longitude = 0.0
            println("no longitude")
        }

        self.content = mNote["content"] as String
        self.context_id = mNote["context"]!["id"] as Int
        self.account_id = mNote["account"]!["id"] as Int
        self.status = mNote["status"] as String
        self.state = STATE.DOWNLOADED
        
        var medias = mNote["medias"] as NSArray
        getMedias(medias)
        return self
    }
    
    
    func getMedias(medias: NSArray) {
        for mediaDict in medias {
            let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
            var media =  SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Media), managedObjectConect: context) as Media
            media.parseMediaJSON(mediaDict as NSDictionary)
            media.note = self
            println("media with note \(media.note.uid) is: { \(media.toString()) }")
            // SwiftCoreDataHelper.saveManagedObjectContext(context)
        }
        
    }
    
    func toString() -> String {
        return "noteid: \(uid) createdAt: \(created_at) latitude: \(latitude) logitutde: \(longitude) status: \(status)"
    }

}
