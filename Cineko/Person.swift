//
//  Person.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class Person: NSManagedObject {

    struct Keys {
        static let Adult = "adult"
        static let AlsoKnownAs = "also_known_as"
        static let Biography = "biography"
        static let Birthday = "birthday"
        static let Deathday = "deathday"
        static let Homepage = "homepage"
        static let Name = "name"
        static let PersonID = "id"
        static let PlaceOfBirth = "place_of_birth"
        static let Popularity = "popularity"
        static let ProfilePath = "profile_path"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Person", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        adult = dictionary[Keys.Adult] as? NSNumber
        alsoKnownAs = dictionary[Keys.AlsoKnownAs] as? NSData
        biography = dictionary[Keys.Biography] as? String
        birthday = dictionary[Keys.Birthday] as? String
        deathday = dictionary[Keys.Deathday] as? String
        homepage = dictionary[Keys.Homepage] as? String
        name = dictionary[Keys.Name] as? String
        personID = dictionary[Keys.PersonID] as? NSNumber
        placeOfBirth = dictionary[Keys.PlaceOfBirth] as? String
        popularity = dictionary[Keys.Popularity] as? NSNumber
        profilePath = dictionary[Keys.ProfilePath] as? String
    }

}

extension Person : ThumbnailTableViewCellDisplayable {
    func id() -> AnyObject? {
        return personID
    }
    
    func path() -> String? {
        return profilePath
    }
    
    func caption() -> String? {
        return name
    }
}