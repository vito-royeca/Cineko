//
//  Review+CoreDataProperties.swift
//  Cineko
//
//  Created by Jovit Royeca on 04/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Review {

    @NSManaged var byline: String?
    @NSManaged var headline: String?
    @NSManaged var link: String?
    @NSManaged var reviewType: String?
    @NSManaged var suggestedLinkText: String?
    @NSManaged var movie: Movie?

}
