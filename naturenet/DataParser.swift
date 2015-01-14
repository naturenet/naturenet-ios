//
//  DataParser.swift
//  nn
//
//  Created by Jinyue Xia on 1/4/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol DataParserProtocol {
     func didReceiveAPIResults(results: NSDictionary)
}

class DataParser {
    var parseService: APIService
    var user : Account?
  
    init() {
        parseService = APIService()
    }
    
//    // parse account info
//    func parseAccount(link: String) {
//        parseService.getResponse(link) {
//            (response) in
//            println(response["data"])
//            var id = response["data"]!["id"] as Int
//            var username = response["data"]!["username"] as String
//            var fullname = response["data"]!["name"] as String
//            var pass = response["data"]!["password"] as String
//            var email = response["data"]!["email"] as String
//            var created_at = response["data"]!["created_at"] as Int
//            
////            self.user = Account(id: id, username: username, fullname: fullname,
////                            password: pass, email: email)
////            var user = Account(
////            self.user!.toString()
//            let appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
//            let context: NSManagedObjectContext = appDelegate.managedObjectContext!
//            
//            let ent = NSEntityDescription.entityForName("Account", inManagedObjectContext: context)!
//            var nuser = Account(entity: ent, insertIntoManagedObjectContext: context)
//            nuser.uid = id
//            nuser.name = fullname
//            nuser.username = username
//            nuser.password = pass
//            nuser.email = email
//            nuser.created_at = created_at
//            context.save(nil)
//            println(nuser)
//        }
//    }
//    
//    func paserNotes(link: String) {
//        parseService.getResponse(link) {
//            (response) in
//            if var notes = response["data"] as? NSArray {
//                for note in notes {
//                    var noteId = note["id"]! as Int
//                    var noteCreatedAt = note["created_at"]! as Int
//                    // println("note id: \(noteId) note createdAt: \(noteCreatedAt) ")
//                }
//            }
//
//        }
//    }
    

}