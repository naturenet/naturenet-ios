//
//  Media.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/27/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData
import UIKit

@objc(Media)
class Media: NNModel {
    
    @NSManaged var thumb_path: String?
    @NSManaged var full_path: String?
    @NSManaged var note_id: NSNumber
    @NSManaged var title: String
    @NSManaged var url: String?
    @NSManaged var note: Note
    
    var apiService: APIService?
    
    func parseMediaJSON(media: NSDictionary) {
        self.uid = media["id"] as Int
        self.url = media["link"] as? String
        self.title = media["title"] as String
        self.created_at = media["created_at"] as NSNumber
//        var createAt = UInt64(media["created_at"] as NSTimeInterval)
//        self.created_at = NSNumber(unsignedLongLong: createAt)
        self.state = STATE.DOWNLOADED
    }

    func toString() -> String {
        return "media id: \(uid) url: \(url) note_id: \(note.uid)"
    }
    
    func getMediaURL() -> String? {
        return self.url
    }
    
    func getNote() -> Note {
        return self.note
    }
    
    func setLocalThumbPath(path: String) {
        let nsManagedContext: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        self.thumb_path = path
        self.setValue(path, forKey: "thumb_path")
        SwiftCoreDataHelper.saveManagedObjectContext(nsManagedContext)
    }
    
    func setLocalFullPath(path: String) {
        let nsManagedContext: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        self.full_path = path
        self.setValue(path, forKey: "full_path")
        SwiftCoreDataHelper.saveManagedObjectContext(nsManagedContext)
    }
    
    override func doPushNew(apiService: APIService) {
        self.apiService = apiService
    }
    
    func doPushNew(apiService: APIService, params: Dictionary<String, Any>) {
        self.apiService = apiService
        var posturl = APIAdapter.api.getCreateMediaLink(self.note.uid.integerValue)
        self.apiService!.post(NSStringFromClass(Media), params: params, url: posturl)
    }
    
}
