//
//  Credit+CoreDataProperties.swift
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

extension Credit {
    
    @NSManaged var castID: NSNumber?
    @NSManaged var character: String?
    @NSManaged var creditID: String?
    @NSManaged var creditType: String?
    @NSManaged var order: NSNumber?

    @NSManaged var job: Job?
    @NSManaged var movie: Movie?
    @NSManaged var person:Person?
    @NSManaged var tvEpisode:TVEpisode?
    @NSManaged var tvSeason:TVSeason?
    @NSManaged var tvShow:TVShow?
}
