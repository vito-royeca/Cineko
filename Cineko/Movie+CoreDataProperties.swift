//
//  Movie+CoreDataProperties.swift
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

extension Movie {

    @NSManaged var adult: NSNumber?
    @NSManaged var backdropPath: String?
    @NSManaged var budget: NSNumber?
    @NSManaged var favorite: NSNumber?
    @NSManaged var homepage: String?
    @NSManaged var imdbID: String?
    @NSManaged var movieID: NSNumber?
    @NSManaged var originalLanguage: String?
    @NSManaged var originalTitle: String?
    @NSManaged var overview: String?
    @NSManaged var popularity: NSNumber?
    @NSManaged var posterPath: String?
    @NSManaged var releaseDate: String?
    @NSManaged var revenue: NSNumber?
    @NSManaged var rtID: String?
    @NSManaged var runtime: NSNumber?
    @NSManaged var status: String?
    @NSManaged var tagline: String?
    @NSManaged var title: String?
    @NSManaged var twitterQuery: String?
    @NSManaged var video: NSNumber?
    @NSManaged var voteAverage: NSNumber?
    @NSManaged var voteCount: NSNumber?
    @NSManaged var watchlist: NSNumber?
    @NSManaged var backdrops: NSSet?
    @NSManaged var credits: NSSet?
    @NSManaged var genres: NSSet?
    @NSManaged var lists: NSSet?
    @NSManaged var posters: NSSet?
    @NSManaged var productionCompanies: NSSet?
    @NSManaged var productionCountries: NSSet?
    @NSManaged var reviews: NSSet?
    @NSManaged var spokenLanguages: NSSet?
}
