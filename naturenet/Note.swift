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
    @NSManaged var context: Context
    @NSManaged var account: Account

    // parse a note JSON
    func parseNoteJSON(mNote: NSDictionary) -> Note {
        self.uid = mNote["id"] as Int
        self.kind = mNote["kind"] as String
        self.created_at = mNote["created_at"] as NSNumber
        self.modified_at = mNote["modified_at"] as NSNumber

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
        var contextID = mNote["context"]!["id"] as Int
        self.context_id = contextID
        var context = NNModel.doPullByUIDFromCoreData(NSStringFromClass(Context), uid: contextID) as Context
        self.context = context
        var accountID = mNote["account"]!["id"] as Int
        self.account_id = accountID
        var account = NNModel.doPullByUIDFromCoreData(NSStringFromClass(Account), uid: accountID) as Account
        self.account = account
        self.status = mNote["status"] as String
        self.state = STATE.DOWNLOADED
        
        var medias = mNote["medias"] as NSArray
        setMedias(medias)
        var feedbacks = mNote["feedbacks"] as NSArray
        setFeedbacks(feedbacks)
        return self
    }
    
    // doCommitChildren
    override func doCommitChildren() {
        for media in getMedias() {
            let noteMedia = media as Media
            noteMedia.commit()
        }
        for feedback in getFeedbacks() {
            let noteFeedback = feedback as Feedback
            noteFeedback.commit()
        }
    }
    
    // give a new note update local, only note description, activity can be updated
    func updateNote(mNote: NSDictionary) {
        self.setValue(mNote["modified_at"] as NSNumber, forKey: "modified_at")
        self.setValue(mNote["content"] as String, forKey: "content")
        if let contextID = mNote["context"]!["id"] as? Int {
            self.setValue(contextID, forKey: "context_id")
            let predicate = NSPredicate(format: "uid = \(contextID)")
            let context = NNModel.fetechEntitySingle(NSStringFromClass(Context), predicate: predicate) as Context
//            var context = NNModel.doPullByUIDFromCoreData(NSStringFromClass(Context), uid: contextID) as Context
            self.setValue(context, forKey: "context")
        }
        self.setValue(STATE.DOWNLOADED, forKey: "state")
        SwiftCoreDataHelper.saveManagedObjectContext(SwiftCoreDataHelper.nsManagedObjectContext)
        println("note with \(self.uid) is: { \(self.toString()) } is updated")
        
        self.commit()
    }
    
    // give a new note save to Note data
    class func saveToCoreData(mNote: NSDictionary) -> Note {
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        var note =  SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Note), managedObjectConect: context) as Note
        note.parseNoteJSON(mNote)
        println("note with \(note.uid) is: { \(note.toString()) } is saved")
        note.commit()
        return note
    }
    
    // given JSON response of medias of a note, save medias into core data
    func setMedias(medias: NSArray) {
        for mediaDict in medias {
            let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
            var media =  SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Media), managedObjectConect: context) as Media
            media.parseMediaJSON(mediaDict as NSDictionary)
            media.note = self
            SwiftCoreDataHelper.saveManagedObjectContext(context)
        }
    }
    
    // given JSON response of medias of a note, save medias into core data
    func setFeedbacks(feedbacks: NSArray) {
        for feedbackDict in feedbacks {
            let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
            var feedback =  SwiftCoreDataHelper.insertManagedObject(NSStringFromClass(Feedback), managedObjectConect: context) as Feedback
            feedback.parseFeedbackJSON(feedbackDict as NSDictionary)
            feedback.note = self
            feedback.target_model = NSStringFromClass(Note)
            // println("feedback with note \(feedback.note.uid) is: { \(feedback.toString()) }")
            SwiftCoreDataHelper.saveManagedObjectContext(context)
        }

    }
    
    // given a note id, get medias from core data
    func getMedias() -> NSArray {
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let request = NSFetchRequest(entityName: NSStringFromClass(Media))
        request.returnsDistinctResults = false
        request.predicate = NSPredicate(format: "note = %@", self.objectID)
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        return results
    }
    
    // get a single media from this note
    func getSingleMedia() -> Media? {
        var media: Media?
        var medias = getMedias() as [Media]
        if medias.count > 0 {
            media = medias[0]
        }
        return media
    }
    
    // given a note id, get feedbacks from core data
    func getFeedbacks() -> NSArray {
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let request = NSFetchRequest(entityName: NSStringFromClass(Feedback))
        request.returnsDistinctResults = false
        request.predicate = NSPredicate(format: "note = %@", self.objectID)
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        return results
    }
    
    // get the landmark(location) from feedback with kind of 'landmark'
    // not straightforward, but this the way how data stored in the server
    func getLandmark() -> String? {
        var landmark: String?
        var feedbacks = getFeedbacks() as [Feedback]
        if feedbacks.count > 0 {
            for feedback in feedbacks {
                if feedback.kind == "landmark" {
                    landmark = feedback.content
                    break
                }
            }
        }
        return landmark
    }
    
    // push a new note to remote server as HTTP post
    // returned JSON will be sent to apiService's delegate: ObservationsController
    override func doPushNew(apiService: APIService) -> Void {
        var url = APIAdapter.api.getCreateNoteLink(Session.getAccount()!.username)
        var params = ["kind": self.kind, "content": self.content, "context": self.context.name,
                        "longitude": self.longitude, "latitude": self.latitude] as Dictionary<String, Any>
        apiService.post(NSStringFromClass(Note), params: params, url: url)
    }
    
    // update an existing note to remote server as HTTP post
    // returned JSON will be sent to apiService's delegate: ObservationsController
    override func doPushUpdate(apiService: APIService) {
        var url = APIAdapter.api.getUpdateNoteLink(self.uid.integerValue)
        var params = ["kind": self.kind, "username": self.account.username, "content": self.content, "context": self.context.name,
            "longitude": self.longitude, "latitude": self.latitude] as Dictionary<String, Any>
        apiService.post(NSStringFromClass(Note), params: params, url: url)
    }
 
    func doPushMedias(apiService: APIService) {
        for media in getMedias() {
            let noteMedia = media as Media
            noteMedia.push(apiService)
        }
    }
    
    func doPushFeedbacks(apiService: APIService) {
        for feedback in getFeedbacks() {
            let noteFeedback = feedback as Feedback
            noteFeedback.push(apiService)
        }
    }
    
    // pushing media and feedback not working well together
    override func doPushChilren(apiService: APIService) {
        for feedback in getFeedbacks() {
            let noteFeedback = feedback as Feedback
            noteFeedback.push(apiService)
        }
        for media in getMedias() {
            let noteMedia = media as Media
            noteMedia.push(apiService)
        }
    }
    
    // toString testing purpose
    func toString() -> String {
        return "noteid: \(uid) modified: \(modified_at) latitude: \(latitude) logitutde: \(longitude) content: \(content)"
    }

}
