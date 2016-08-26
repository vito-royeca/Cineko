//
//  TVShow+CoreDataProperties.swift
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

extension TVShow {

    @NSManaged var backdropPath: String?
    @NSManaged var favorite: NSNumber?
    @NSManaged var firstAirDate: String?
    @NSManaged var homepage: String?
    @NSManaged var inProduction: NSNumber?
    @NSManaged var lastAirDate: String?
    @NSManaged var name: String?
    @NSManaged var numberOfEpisodes: NSNumber?
    @NSManaged var numberOfSeasons: NSNumber?
    @NSManaged var originalLanguage: String?
    @NSManaged var originalName: String?
    @NSManaged var overview: String?
    @NSManaged var popularity: NSNumber?
    @NSManaged var posterPath: String?
    @NSManaged var status: String?
    @NSManaged var tvShowID: NSNumber?
    @NSManaged var tvShowType: String?
    @NSManaged var twitterQuery: String?
    @NSManaged var voteAverage: NSNumber?
    @NSManaged var voteCount: NSNumber?
    @NSManaged var watchlist: NSNumber?
    @NSManaged var backdrops: NSSet?
    @NSManaged var credits: NSSet?
    @NSManaged var genres: NSSet?
    @NSManaged var networks: NSSet?
    @NSManaged var posters: NSSet?
    @NSManaged var productionCompanies: NSSet?
    @NSManaged var tvSeasons: NSSet?
    @NSManaged var videos: NSSet?
}
