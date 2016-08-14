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
    
    func movieReviews(movieID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw NYTimesReviewError.NoAPIKey
        }
        
        var movie:Movie?
        let fetchRequest = NSFetchRequest(entityName: "Movie")
        fetchRequest.predicate = NSPredicate(format: "movieID == %@", movieID)
        
        do {
            movie = try CoreDataManager.sharedInstance.privateContext.executeFetchRequest(fetchRequest).first as? Movie
        } catch {}
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(NYTimesReviewConstants.APIURL)\(NYTimesReviewConstants.Reviews.Search.Path)"
        let parameters = [NYTimesReviewConstants.APIKey: apiKey!,
                          "query": "'\(movie!.title!)'"]
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for review in json {
                        let m = ObjectManager.sharedInstance.findOrCreateReview(review)
                        m.movie = movie
                    }
                }
            }
            CoreDataManager.sharedInstance.savePrivateContext()
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
