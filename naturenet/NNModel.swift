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
    @NSManaged var uID: NSNumber
    @NSManaged var created_at: NSNumber
    @NSManaged var state: NSNumber
    
    struct State {
        static let NEW = 1
        static let SAVED = 2
        static let MODIFIED = 3
        static let SYNCED = 4
        static let DOWNLOADED = 5
    }
    
}

