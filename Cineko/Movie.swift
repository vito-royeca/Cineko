//
//  Movie.swift
//  Cineko
//
//  Created by Jovit Royeca on 06/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

class Movie: NSManagedObject {
    
    struct Keys {
        static let Adult = "adult"
        static let BackdropPath = "backdrop_path"
        static let Budget = "budget"
        static let Homepage = "homepage"
        static let IMDBID = "imdb_id"
        static let MovieID = "id"
        static let OriginalLanguage = "original_language"
        static let OriginalTitle = "original_title"
        static let Overview = "overview"
        static let Popularity = "popularity"
        static let PosterPath = "poster_path"
        static let ReleaseDate = "release_date"
        static let Revenue = "revenue"
        static let Runtime = "runtime"
        static let Status = "status"
        static let Tagline = "tagline"
        static let Title = "title"
        static let Video = "video"
        static let VoteAverage = "vote_average"
        static let VoteCount = "vote_count"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Movie", inManagedObjectContext: context)!
        super.init(entity: entity,insertIntoManagedObjectContext: context)
        
        update(dictionary)
    }
    
    func update(dictionary: [String : AnyObject]) {
        adult = dictionary[Keys.Adult] as? NSNumber
        backdropPath = dictionary[Keys.BackdropPath] as? String
        budget = dictionary[Keys.Budget] as? NSNumber
        homepage = dictionary[Keys.Homepage] as? String
        imdbID = dictionary[Keys.IMDBID] as? String
        movieID = dictionary[Keys.MovieID] as? NSNumber
        originalLanguage = dictionary[Keys.OriginalLanguage] as? String
        originalTitle = dictionary[Keys.OriginalTitle] as? String
        overview = dictionary[Keys.Overview] as? String
        popularity = dictionary[Keys.Popularity] as? NSNumber
        posterPath = dictionary[Keys.PosterPath] as? String
        releaseDate = dictionary[Keys.ReleaseDate] as? String
        revenue = dictionary[Keys.Revenue] as? NSNumber
        runtime = dictionary[Keys.Runtime] as? NSNumber
        status = dictionary[Keys.Status] as? String
        tagline = dictionary[Keys.Tagline] as? String
        title = dictionary[Keys.Title] as? String
        video = dictionary[Keys.Video] as? NSNumber
        voteAverage = dictionary[Keys.VoteAverage] as? NSNumber
        voteCount = dictionary[Keys.VoteCount] as? NSNumber
    }
    
    func runtimeToString() -> String? {
        if let runtime = runtime {
            let duration = runtime.integerValue
            let minutes = duration % 60;
            let hours = duration / 60
            return "\(hours)hr \(minutes)min"
            
        }
        
        return nil
    }
}

extension Movie : ThumbnailDisplayable {
    func imagePath(displayType: DisplayType) -> String? {
        switch displayType {
        case .Poster:
            return posterPath
        case .Backdrop:
            return backdropPath
        case .Profile:
            return nil
        }
    }
    
    func caption(captionType: CaptionType) -> String? {
        return title
    }
}