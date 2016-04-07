//
//  ProductionCompany+CoreDataProperties.swift
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

extension Company {

    @NSManaged var companyDescription: String?
    @NSManaged var companyID: NSNumber?
    @NSManaged var headquarters: String?
    @NSManaged var homepage: String?
    @NSManaged var logoPath: String?
    @NSManaged var name: String?
    @NSManaged var movies: NSSet?
    @NSManaged var tvShows: NSSet?

}
