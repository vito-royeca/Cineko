//
//  Person+CoreDataProperties.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Person {
    
    @NSManaged var adult: NSNumber?
    @NSManaged var alsoKnownAs: NSData?
    @NSManaged var biography: String?
    @NSManaged var birthday: String?
    @NSManaged var deathday: String?
    @NSManaged var homepage: String?
    @NSManaged var name: String?
    @NSManaged var personID: NSNumber?
    @NSManaged var placeOfBirth: String?
    @NSManaged var popularity: NSNumber?
    @NSManaged var profilePath: String?
    
}
