//
//  List.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class List: NSManagedObject {

    struct Keys {
        static let Description = "description"
        static let FavoriteCount = "favorite_count"
        static let ISO6391 = "iso_639_1"
        static let ItemCount = "item_count"
        static let ListID = "id"
        static let ListType = "list_type"
        static let Name = "name"
        static let PosterPath = "poster_path"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("List", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        description_ = dictionary[Keys.Description] as?  String
        favoriteCount = dictionary[Keys.FavoriteCount] as?  NSNumber
        iso6391 = dictionary[Keys.ISO6391] as?  String
        itemCount = dictionary[Keys.ItemCount] as?  NSNumber
        listID = dictionary[Keys.ListID] as?  String
        listType = dictionary[Keys.ListType] as?  String
        name = dictionary[Keys.Name] as?  String
        posterPath = dictionary[Keys.PosterPath] as? String
    }
}
