//
//  NNModel.swift
//  nn
//
//  Created by Jinyue Xia on 1/11/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData

class NNModel: NSManagedObject {
    @NSManaged var uid: NSNumber
    @NSManaged var created_at: NSNumber
    @NSManaged var modified_at: NSNumber
    @NSManaged var state: NSNumber

    struct STATE {
        static let NEW = 1
        static let SAVED = 2
        static let MODIFIED = 3
        static let SYNCED = 4
        static let DOWNLOADED = 5
    }
    
    func commit() -> Void {
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        if (state == STATE.NEW || state == STATE.SAVED){
            state = STATE.SAVED
        } else if (state == STATE.SYNCED || state == STATE.MODIFIED){
            state = STATE.MODIFIED
        } else if (state == STATE.DOWNLOADED) {
            state = STATE.SYNCED
        }
        doCommitChildren();
        SwiftCoreDataHelper.saveManagedObjectContext(context)
    }
    
//    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
//        super.init(entity: entity, insertIntoManagedObjectContext: context?)
//        self.state = STATE.NEW
//    }
    
    // pull information from coredata
    class func doPullByNameFromCoreData(entityname: String, attr: String, name: String?) -> NNModel? {
        var model: NNModel?
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let request = NSFetchRequest(entityName: entityname)
        request.returnsDistinctResults = false
        if name != nil {
            request.predicate = NSPredicate(format: "\(attr) = %@", name!)
        }
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        if results.count > 0 {
            for res in results {
                if let tModel = res as? NNModel {
                    model = tModel
                }
            }
        } else {
            println("no matched in doPullByNameFromCoreData")
        }
        return model
    }
    
    // pull information from coredata
    class func doPullByUIDFromCoreData(entityname: String, uid: Int) -> NNModel? {
        var model: NNModel?
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let request = NSFetchRequest(entityName: entityname)
        request.returnsDistinctResults = false
        request.predicate = NSPredicate(format: "uid = \(uid)")
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        if results.count > 0 {
            for res in results {
                if let tModel = res as? NNModel {
                    model = tModel
                }
            }
        } else {
            println("no matched in doPullByUIDFromCoreData")
        }
        return model
    }
    
    // pull information from coredata
    class func doPullByObjcIDFromCoreData(entityname: String, objectID: NSManagedObjectID) -> NNModel? {
        var model: NNModel?
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let request = NSFetchRequest(entityName: entityname)
        request.returnsDistinctResults = false
        request.predicate = NSPredicate(format: "SELF = %@", objectID)
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        if results.count > 0 {
            for res in results {
                if let tModel = res as? NNModel {
                    model = tModel
                }
            }
        } else {
            println("no matched in doPullByUIDFromCoreData")
        }
        return model
    }

    // update remote uid and state
    func updateAfterPost(idFromServer: Int, modifiedAtFromServer: Int?) {
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        state = STATE.SYNCED
        uid = idFromServer
        if modifiedAtFromServer != nil {
            modified_at = modifiedAtFromServer!
        }
        SwiftCoreDataHelper.saveManagedObjectContext(context)
    }

    func doPushNew(apiService: APIService) -> Void {}
    
    func doPushChilren(apiService: APIService) {}

    func doUpdataState() {}
    
    func doCommitChildren() {}
    
    func resolveDependencies() {}
}

