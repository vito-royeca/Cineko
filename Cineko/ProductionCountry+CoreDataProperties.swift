//
//  ProductionCountry+CoreDataProperties.swift
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

extension ProductionCountry {

    @NSManaged var name: String?
    @NSManaged var iso31661: String?
    @NSManaged var movies: NSSet?

}
