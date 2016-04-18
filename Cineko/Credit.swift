//
//  Credit.swift
//  Cineko
//
//  Created by Jovit Royeca on 07/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

class Credit: NSManagedObject {

    struct Keys {
        static let CastID = "cast_id"
        static let Character = "character"
        static let CreditID = "credit_id"
        static let CreditType = "credit_type"
        static let Order = "order"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Credit", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        castID = dictionary[Keys.CastID] as? NSNumber
        character = dictionary[Keys.Character] as? String
        creditID = dictionary[Keys.CreditID] as? String
        creditType = dictionary[Keys.CreditType] as? String
        order = dictionary[Keys.Order] as? NSNumber
    }
}

extension Credit : ThumbnailTableViewCellDisplayable {
    func id() -> AnyObject? {
        return creditID
    }
    
    func path() -> String? {
        if let creditType = creditType {
            if creditType == "cast" ||
                creditType == "crew"{
                return person?.profilePath
                
            } else if creditType == "guest_star" {
                
            }
        }
        
        return nil
    }
    
    func caption() -> String? {
        var caption = ""
        
        if let creditType = creditType {
            if creditType == "cast" {
                caption += "\(person!.name!)"
                if let character = character {
                    if !character.isEmpty {
                        caption += "\nas \(character)"
                    }
                }
                
            } else if creditType == "crew" {
                caption += "\(person!.name!)"
                caption += "\n\(job!.name!)"
                
            } else if creditType == "guest_star" {
                
            }
        }
        
        return caption
    }
}
