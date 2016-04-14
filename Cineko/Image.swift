//
//  Image.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Image: NSManagedObject {

    struct Keys {
        static let AspectRatio = "aspect_ratio"
        static let FilePath = "file_path"
        static let Height = "height"
        static let ISO6391 = "iso_639_1"
        static let VoteAverage = "vote_average"
        static let VoteCount = "vote_count"
        static let Width = "width"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Image", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        aspectRatio = dictionary[Keys.AspectRatio] as? NSNumber
        filePath = dictionary[Keys.FilePath] as? String
        height = dictionary[Keys.Height] as? NSNumber
        iso6391 = dictionary[Keys.ISO6391] as? String
        voteAverage = dictionary[Keys.VoteAverage] as? NSNumber
        voteCount = dictionary[Keys.VoteCount] as? NSNumber
        width = dictionary[Keys.Width] as? NSNumber
    }

}

extension Image : ThumbnailTableViewCellDisplayable {
    func id() -> AnyObject? {
        return filePath
    }
    
    func path() -> String? {
        return filePath
    }
    
    func caption() -> String? {
        return nil
    }
}