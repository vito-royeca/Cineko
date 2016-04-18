//
//  TVSeason+CoreDataProperties.swift
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

extension TVSeason {
    
    @NSManaged var airDate: String?
    @NSManaged var episodeCount: NSNumber?
    @NSManaged var name: String?
    @NSManaged var overview: String?
    @NSManaged var posterPath: String?
    @NSManaged var seasonNumber: NSNumber?
    @NSManaged var tvSeasonID: NSNumber?
    @NSManaged var credits: NSSet?
    @NSManaged var tvEpisodes: NSSet?
    @NSManaged var tvShow: TVShow?
}
