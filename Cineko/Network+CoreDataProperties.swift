//
//  Network+CoreDataProperties.swift
//  Cineko
//
//  Created by Jovit Royeca on 07/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Network {

    @NSManaged var name: String?
    @NSManaged var networkID: NSNumber?
    @NSManaged var tvShows: NSSet?
}
