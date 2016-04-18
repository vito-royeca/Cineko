//
//  TVEpisode.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

class TVEpisode: NSManagedObject {

    struct Keys {
        static let AirDate = "air_date"
        static let EpisodeID = "id"
        static let EpisodeNumber = "episode_number"
        static let Name = "name"
        static let Overview = "overview"
        static let ProductionCode = "production_code"
        static let SeasonNumber = "season_number"
        static let StillPath = "still_path"
        static let VoteAverage = "vote_average"
        static let VoteCount = "vote_count"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("TVEpisode", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        airDate = dictionary[Keys.Name] as? String
        episodeID = dictionary[Keys.Name] as? NSNumber
        episodeNumber = dictionary[Keys.Name] as? NSNumber
        name = dictionary[Keys.Name] as? String
        overview = dictionary[Keys.Name] as? String
        productionCode = dictionary[Keys.Name] as? String
        seasonNumber = dictionary[Keys.Name] as? NSNumber
        stillPath = dictionary[Keys.Name] as? String
        voteAverage = dictionary[Keys.Name] as? NSNumber
        voteCount = dictionary[Keys.Name] as? NSNumber
    }

}
