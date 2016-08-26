//
//  MovieVideo.swift
//  Cineko
//
//  Created by Jovit Royeca on 25/08/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class MovieVideo: NSManagedObject {

    struct Keys {
        static let MovieVideoID = "id"
        static let ISO6391 = "iso_639_1"
        static let Key = "key"
        static let Name = "name"
        static let Site = "Site"
        static let Size = "size"
        static let VideoType = "type"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("MovieVideo", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        movieVideoID = dictionary[Keys.MovieVideoID] as? String
        iso6391 = dictionary[Keys.ISO6391] as? String
        key = dictionary[Keys.Key] as? String
        name = dictionary[Keys.Name] as? String
        site = dictionary[Keys.Site] as? String
        size = dictionary[Keys.Size] as? NSNumber
        videoType = dictionary[Keys.VideoType] as? String
    }

}
