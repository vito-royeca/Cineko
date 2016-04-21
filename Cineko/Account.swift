//
//  Account.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

class Account: NSManagedObject {

    struct Keys {
        static let AccountID = "id"
        static let Avatar = "avatar"
        static let Gravatar = "gravatar"
        static let Hash = "hash"
        static let ISO6391 = "iso_639_1"
        static let ISO31661 = "iso_3166_1"
        static let Name = "name"
        static let IncludeAdult = "include_adult"
        static let Username = "username"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Account", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        accountID = dictionary[Keys.AccountID] as? NSNumber
        if let avatarDict = dictionary[Keys.Avatar] as? [String: AnyObject] {
            if let gravatarDict = avatarDict[Keys.Gravatar] as? [String: AnyObject] {
                if let hash = gravatarDict[Keys.Hash] as? String {
                    gravatarHash = hash
                }
            }
        }
        includeAdult = dictionary[Keys.IncludeAdult] as? NSNumber
        iso6391 = dictionary[Keys.ISO6391] as? String
        iso31661 = dictionary[Keys.ISO31661] as? String
        name = dictionary[Keys.Name] as? String
        username = dictionary[Keys.Username] as? String

    }

}
