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

extension Credit : ThumbnailDisplayable {
    func imagePath(displayType: DisplayType) -> String? {
        switch displayType {
        case .Poster, .Backdrop:
            if movie != nil && tvShow == nil {
                return movie!.imagePath(displayType)
            } else if movie == nil && tvShow != nil {
                return tvShow!.imagePath(displayType)
            }
        case .Profile:
            if let person = person {
                return person.imagePath(displayType)
            }
        }
        
        return nil
    }
    
    func caption(captionType: CaptionType) -> String? {
        switch captionType {
        case .Title:
            if movie != nil && tvShow == nil {
                return movie!.caption(captionType)
            } else if movie == nil && tvShow != nil {
                return tvShow!.caption(captionType)
            }
        case .Name:
            if let person = person {
                return person.name
            }
        case .Job:
            if let job = job {
                return job.name
            }
        case .Role:
            if let character = character {
                return "as \(character)"
            }
        case .NameAndJob:
            if let person = person,
                let job = job {
                return "\(person.name!)\n\(job.name!)"
            }
        case .NameAndRole:
            if let person = person,
                let character = character {
                return "\(person.name!)\nas \(character)"
            }
        }
        
        return nil
    }
}
