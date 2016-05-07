//
//  List+CoreDataProperties.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension List {

    @NSManaged var description_: String?
    @NSManaged var favoriteCount: NSNumber?
    @NSManaged var iso6391: String?
    @NSManaged var itemCount: NSNumber?
    @NSManaged var listID: String?
    @NSManaged var listType: String?
    @NSManaged var name: String?
    @NSManaged var posterPath: String?
    @NSManaged var createdBy: Account?
    @NSManaged var movies: NSSet?
}
