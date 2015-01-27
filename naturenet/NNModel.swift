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
        if (state == STATE.NEW || state == STATE.SAVED){
            state = STATE.SAVED
            doUpdataState()
        } else if (state == STATE.SYNCED || state == STATE.MODIFIED){
            state = STATE.MODIFIED
            doUpdataState()
        } else if (state == STATE.DOWNLOADED) {
            resolveDependencies()
            state = STATE.SYNCED
            doUpdataState()
        }
        doCommitChildren();
    
    }
    
    func doUpdataState() {}
    
    func doCommitChildren() {}
    
    func resolveDependencies() {}
}

