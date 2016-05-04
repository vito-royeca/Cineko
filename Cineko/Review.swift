//
//  Review.swift
//  Cineko
//
//  Created by Jovit Royeca on 04/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Review: NSManagedObject {

    struct Keys {
        static let Byline = "byline"
        static let Headline = "headline"
        static let Link = "url"
        static let SuggestedLinkText = "suggested_link_text"
        static let ReviewType = "type"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Review", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        byline = dictionary[Keys.Byline] as? String
        headline = dictionary[Keys.Headline] as? String
        
        if let linkDict = dictionary["link"] as? [String: AnyObject] {
            link = linkDict[Keys.Link] as? String
            suggestedLinkText = linkDict[Keys.SuggestedLinkText] as? String
            reviewType = linkDict[Keys.ReviewType] as? String
        }
    }
}
