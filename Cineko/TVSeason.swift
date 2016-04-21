//
//  TVSeason.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

class TVSeason: NSManagedObject {

    struct Keys {
        static let AirDate = "air_date"
        static let EpisodeCount = "episode_count"
        static let Name = "name"
        static let Overview = "overview"
        static let PosterPath = "poster_path"
        static let SeasonNumber = "season_number"
        static let TVSeasonID = "id"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("TVSeason", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        airDate = dictionary[Keys.AirDate] as? String
        episodeCount = dictionary[Keys.EpisodeCount] as? NSNumber
        name = dictionary[Keys.Name] as? String
        overview = dictionary[Keys.Overview] as? String
        posterPath = dictionary[Keys.PosterPath] as? String
        seasonNumber = dictionary[Keys.SeasonNumber] as? NSNumber
        tvSeasonID = dictionary[Keys.TVSeasonID] as? NSNumber
    }
}

extension TVSeason : ThumbnailDisplayable {
    func imagePath(displayType: DisplayType) -> String? {
        return posterPath
    }
    
    func caption(captionType: CaptionType) -> String? {
        if let seasonNumber = seasonNumber {
            return "Season \(seasonNumber.integerValue)"
        }
        return nil
    }
}
