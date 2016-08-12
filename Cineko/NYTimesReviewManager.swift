//
//  NYTimesReviewManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import CoreData

enum NYTimesReviewError: ErrorType {
    case NoAPIKey
}


struct NYTimesReviewConstants {
    static let APIKey          = "api-key"
    static let APIURL          = "https://api.nytimes.com/svc/movies/v2"
    
    struct Reviews {
        struct Search {
            static let Path = "/reviews/search.json"
        }
    }
}

class NYTimesReviewManager: NSObject {
    // MARK: Variables
    private var apiKey:String?
    
    // MARK: Setup
    func setup(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func movieReviews(movieID: NSManagedObjectID, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw NYTimesReviewError.NoAPIKey
        }
        
        let movie = CoreDataManager.sharedInstance.mainObjectContext.objectWithID(movieID) as! Movie
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(NYTimesReviewConstants.APIURL)\(NYTimesReviewConstants.Reviews.Search.Path)"
        let parameters = [NYTimesReviewConstants.APIKey: apiKey!,
                          "query": "'\(movie.title!)'"]
        var reviewIDs = [AnyObject]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for review in json {
                        let m = ObjectManager.sharedInstance.findOrCreateReview(review)
                        reviewIDs.append(m.objectID)
                    }
                }
            }
            ObjectManager.sharedInstance.updateMovie([Movie.Keys.MovieID: movie.movieID!], reviewIDs: reviewIDs)
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance.exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    // MARK: Shared Instance
    static let sharedInstance = NYTimesReviewManager()
}
