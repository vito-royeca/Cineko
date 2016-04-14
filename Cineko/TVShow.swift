//
//  TVShow.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData


class TVShow: NSManagedObject {

    struct Keys {
        static let BackdropPath = "backdrop_path"
        static let FirstAirDate = "first_air_date"
        static let Homepage = "homepage"
        static let InProduction = "in_production"
        static let Languages = "languages"
        static let LastAirDate = "last_air_date"
        static let Name = "name"
        static let NumberOfEpisodes = "number_of_episodes"
        static let NumberOfSeasons = "number_of_seasons"
        static let OriginalLanguage = "original_language"
        static let OriginalName = "original_name"
        static let OriginCountry = "origin_country"
        static let Overview = "overview"
        static let Popularity = "popularity"
        static let PosterPath = "poster_path"
        static let Status = "status"
        static let TVShowID = "id"
        static let TVShowType = "type"
        static let VoteAverage = "vote_average"
        static let VoteCount = "vote_count"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("TVShow", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        backdropPath = dictionary[Keys.BackdropPath] as? String
        firstAirDate = dictionary[Keys.FirstAirDate] as? String
        homepage = dictionary[Keys.Homepage] as? String
        inProduction = dictionary[Keys.InProduction] as? NSNumber
        languages = dictionary[Keys.Languages] as? NSData
        lastAirDate = dictionary[Keys.LastAirDate] as? String
        name = dictionary[Keys.Name] as? String
        numberOfEpisodes = dictionary[Keys.NumberOfEpisodes] as? NSNumber
        numberOfSeasons = dictionary[Keys.NumberOfSeasons] as? NSNumber
        originalLanguage = dictionary[Keys.OriginalLanguage] as? String
        originalName = dictionary[Keys.OriginalName] as? String
        originCountry = dictionary[Keys.OriginCountry] as? NSData
        overview = dictionary[Keys.Overview] as? String
        popularity = dictionary[Keys.Popularity] as? NSNumber
        posterPath = dictionary[Keys.PosterPath] as? String
        status = dictionary[Keys.Status] as? String
        tvShowID = dictionary[Keys.TVShowID] as? NSNumber
        tvShowType = dictionary[Keys.TVShowType] as? String
        voteAverage = dictionary[Keys.VoteAverage] as? NSNumber
        voteCount = dictionary[Keys.VoteCount] as? NSNumber
    }
}

extension TVShow : ThumbnailTableViewCellDisplayable {
    func id() -> AnyObject? {
        return tvShowID
    }
    
    func path() -> String? {
        return posterPath
    }
    
    func caption() -> String? {
        return name
    }
}