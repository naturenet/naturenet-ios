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
class Media: NNModel, CLUploaderDelegate {
    
    @NSManaged var thumb_path: String?
    @NSManaged var full_path: String?
    @NSManaged var note_id: NSNumber
    @NSManaged var title: String
    @NSManaged var url: String?
    @NSManaged var note: Note
    
    var cloudinary:CLCloudinary = CLCloudinary()
    var apiService: APIService?
    
    func parseMediaJSON(media: NSDictionary) {
        self.uid = media["id"] as Int
        self.url = media["link"] as? String
        self.title = media["title"] as String
        self.created_at = media["created_at"] as Int
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
        self.uploadToCloudinary()
    }
    
    //----------------------------------------------------------------------------------------------
    // cloudinary
    func uploadToCloudinary(){
        var image = UIImage(named: self.full_path!)
        let forUpload = UIImageJPEGRepresentation(image, 0.8) as NSData
        cloudinary.config().setValue("university-of-colorado", forKey: "cloud_name")
        cloudinary.config().setValue("893246586645466", forKey: "api_key")
        cloudinary.config().setValue("8Liy-YcDCvHZpokYZ8z3cUxCtyk", forKey: "api_secret")
        let uploader = Wrappy.create(cloudinary, delegate: self)
        uploader.upload(forUpload, options: nil, withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
    }
    
    func onCloudinaryCompletion(successResult:[NSObject : AnyObject]!, errorResult:String!, code:Int, idContext:AnyObject!) {
        let publicId = successResult["public_id"] as String
        self.url = successResult["url"] as? String
        println("cloudinary id is: \(publicId)")
        // push media after cloudinary is finished
        var posturl = APIAdapter.api.getCreateMediaLink(self.note.uid.integerValue)
//        var urlArr = split(self.url) {$0 == "/"}
        var params = ["link": publicId] as Dictionary<String, Any>
        self.apiService!.post(NSStringFromClass(Media), params: params, url: posturl)
    }
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:AnyObject!) {
        //do any progress update you may need
    }
}
