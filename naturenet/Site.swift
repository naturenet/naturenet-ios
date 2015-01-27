//
//  Site.swift
//  naturenet
//
//  Created by Jinyue Xia on 1/26/15.
//  Copyright (c) 2015 Jinyue Xia. All rights reserved.
//

import Foundation
import CoreData

@objc(Site)
class Site: NNModel {
    @NSManaged var site_description: String
    @NSManaged var image_url: String
    @NSManaged var name: String
    @NSManaged var kind: String
    @NSManaged var contexts: NSArray
    
    // pull info from remote server
    class func doPullByNameFromServer(parseService: APIService, name: String) {
        var siteUrl = APIAdapter.api.getSiteLink(name)
        parseService.getResponse(NSStringFromClass(Site), url: siteUrl)
    }
    
    // pull information from coredata
    class func doPullByNameFromCoreData(name: String) -> Site? {
        var site: Site?
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let request = NSFetchRequest(entityName: "Site")
        request.returnsDistinctResults = false
        request.predicate = NSPredicate(format: "name = %@", name)
        var results: NSArray = context.executeFetchRequest(request, error: nil)!
        if results.count > 0 {
            for res in results {
                if let tSite = res as? Site {
                    site = tSite
                }
            }
        } else {
            println("no site matched in site's doPullByNameFromCoreData")
        }
        return site
    }
    
    // save a new site in coredata
    class func createInManagedObjectContext(name: String, uid: Int, description: String, imageURL: String) -> Site {
        let context: NSManagedObjectContext = SwiftCoreDataHelper.nsManagedObjectContext
        let ent = NSEntityDescription.entityForName("Site", inManagedObjectContext: context)!
        let newSite = Site(entity: ent, insertIntoManagedObjectContext: context)
        newSite.created_at = NSDate().timeIntervalSince1970
        newSite.name = name
        newSite.uid = uid
        newSite.site_description = description
        newSite.image_url = imageURL
        newSite.state = STATE.DOWNLOADED
        context.save(nil)
        println("newSite is : \(newSite)" + "Site entity is: \(newSite.toString())")
        return newSite
    }
    
    func toString() -> String {
        var string = "name: \(name) uid: \(uid) created: \(created_at) state: \(state)"
        return string
    }
    
//    override func resolveDependencies() {
//        if (contexts.count > 0) {
//            for context in contexts {
//                if let tContext = context as? Context {
//                    tContext.state = STATE.DOWNLOADED
//                }
//            }
//        }
//    }

}
