//
//  TVEpisode+CoreDataProperties.swift
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

extension TVEpisode {

    @NSManaged var airDate: String?
    @NSManaged var episodeID: NSNumber?
    @NSManaged var episodeNumber: NSNumber?
    @NSManaged var name: String?
    @NSManaged var overview: String?
    @NSManaged var productionCode: String?
    @NSManaged var seasonNumber: NSNumber?
    @NSManaged var stillPath: String?
    @NSManaged var voteAverage: NSNumber?
    @NSManaged var voteCount: NSNumber?
    @NSManaged var credits: NSSet?
    @NSManaged var tvSeason: TVSeason?
}
