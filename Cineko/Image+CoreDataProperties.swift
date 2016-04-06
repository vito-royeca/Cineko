//
//  Image+CoreDataProperties.swift
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

extension Image {

    @NSManaged var filePath: String?
    @NSManaged var width: NSNumber?
    @NSManaged var height: NSNumber?
    @NSManaged var iso6391: String?
    @NSManaged var aspectRatio: NSNumber?
    @NSManaged var voteAverage: NSNumber?
    @NSManaged var voteCount: NSNumber?
    @NSManaged var moviePosters: NSSet?
    @NSManaged var movieBackdrops: NSSet?

}
