//
//  TMDBManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 04/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import KeychainAccess
import CoreData

enum TMDBError: ErrorType {
    case NoAPIKey
    case NoSessionID
}

struct TMDBConstants {
    static let APIKey          = "api_key"
    static let APIURL          = "https://api.themoviedb.org/3"
    static let SignupURL       = "https://www.themoviedb.org/account/signup"
    static let AuthenticateURL = "https://www.themoviedb.org/authenticate"
    static let ImageURL        = "https://image.tmdb.org/t/p"
    
    static let BackdropSizes = [
        "w300",
        "w780",
        "w1280",
        "original"]
    
    static let LogoSizes = [
        "w45",
        "w92",
        "w154",
        "w185",
        "w300",
        "w500",
        "original"]
    
    static let PosterSizes = [
        "w92",
        "w154",
        "w185",
        "w342",
        "w500",
        "w780",
        "original"]
    
    static let ProfileSizes = [
        "w45",
        "w92", // not include in TMDB configuration
        "w185",
        "h632",
        "original"]
    
    static let StillSizes = [
        "w92",
        "w185",
        "w300",
        "original"]
    
    struct iPad {
        struct Keys {
            static let RequestToken     = "request_token"
            static let RequestTokenDate = "request_token_date"
            static let SessionID        = "session_id"
        }
    }
    
    struct Authentication {
        struct TokenNew {
            static let Path = "/authentication/token/new"
            struct Keys {
                static let RequestToken = "request_token"
            }
        }
        
        struct SessionNew {
            static let Path = "/authentication/session/new"
            struct Keys {
                static let SessionID = "session_id"
            }
        }
    }
    
    struct Movies {
        struct NowPlaying {
            static let Path = "/movie/now_playing"
        }
        
        struct ID {
            static let Path = "/movie/{id}"
        }
        
        struct Images {
            static let Path = "/movie/{id}/images"
        }
    }
    
    struct TVShows {
        struct OnTheAir {
            static let Path = "/tv/on_the_air"
        }
        struct AiringToday {
            static let Path = "/tv/airing_today"
        }
    }
    
    struct People {
        struct Popular {
            static let Path = "/person/popular"
        }
    }
}

class TMDBManager: NSObject {
    let keychain = Keychain(server: "\(TMDBConstants.APIURL)", protocolType: .HTTPS)

    // MARK: Variables
    private var apiKey:String?
    private var sharedContext: NSManagedObjectContext {
        return CoreDataManager.sharedInstance().managedObjectContext
    }
    
    // MARK: Setup
    func setup(apiKey: String) {
        self.apiKey = apiKey
        checkFirstRun()
    }
    
    // MARK: iPad
    func checkFirstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("FirstRun") {
            // remove prior keychain items if this is our first run
            TMDBManager.sharedInstance().keychain[TMDBConstants.iPad.Keys.SessionID] = nil
            TMDBManager.sharedInstance().keychain[TMDBConstants.iPad.Keys.RequestToken] = nil
            NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.iPad.Keys.RequestTokenDate)
            
            // then mark this us our first run
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstRun")
        }
    }
    
    func getAvailableRequestToken() throws -> String? {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        if let requestToken = keychain[TMDBConstants.iPad.Keys.RequestToken],
            let requestTokenDate = NSUserDefaults.standardUserDefaults().valueForKey(TMDBConstants.iPad.Keys.RequestTokenDate) as? NSDate {
            
            // let's calculate the age of the request token
            let interval = requestTokenDate.timeIntervalSinceNow
            let secondsInAnHour:Double = 3600
            let elapsedTime = abs(interval / secondsInAnHour)
            
            // request token's expiration is 1 hour
            if elapsedTime <= 60 {
                return requestToken
                
            } else {
                TMDBManager.sharedInstance().keychain[TMDBConstants.iPad.Keys.SessionID] = nil
                TMDBManager.sharedInstance().keychain[TMDBConstants.iPad.Keys.RequestToken] = nil
                NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.iPad.Keys.RequestTokenDate)
            }
        }
        
        return nil
    }
    
    func saveRequestToken(requestToken: String) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        TMDBManager.sharedInstance().keychain[TMDBConstants.iPad.Keys.RequestToken] = requestToken
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: TMDBConstants.iPad.Keys.RequestTokenDate)
    }
    
    func removeRequestToken() throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        TMDBManager.sharedInstance().keychain[TMDBConstants.iPad.Keys.RequestToken] = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.iPad.Keys.RequestTokenDate)
    }
    
    func saveSessionID(sessionID: String) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        TMDBManager.sharedInstance().keychain[TMDBConstants.iPad.Keys.SessionID] = sessionID
    }
    
    func hasSessionID() -> Bool {
        return TMDBManager.sharedInstance().keychain[TMDBConstants.iPad.Keys.SessionID] != nil
    }
    
    // MARK: TMDB Authentication
    func authenticationTokenNew(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Authentication.TokenNew.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func authenticationSessionNew(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        if let requestToken = try getAvailableRequestToken() {
            let httpMethod:HTTPMethod = .Get
            let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Authentication.SessionNew.Path)"
            let parameters = [TMDBConstants.APIKey: apiKey!,
                              TMDBConstants.Authentication.TokenNew.Keys.RequestToken: requestToken]
            
            NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
        
        } else {
            failure(error: NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey : "No request token available."]))
        }
    }
    
    // MARK: TMDB Movies
    func moviesNowPlaying(completion: (arrayIDs: [AnyObject]?, error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Movies.NowPlaying.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            var movieIDs = [NSNumber]()
            
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for movie in json {
                        if let m = self.findOrCreateMovie(movie) {
                            movieIDs.append(m.movieID!)
                        }
                    }
                }
            }
            
            completion(arrayIDs: movieIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: nil, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func movieDetails(movieID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Movies.ID.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(movieID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
    
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let m = self.findOrCreateMovie(dict) {
                    m.update(dict)
                    CoreDataManager.sharedInstance().saveContext()
                }
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func moviesImages(movieID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Movies.Images.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(movieID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            let movie = self.findOrCreateMovie([Movie.Keys.MovieID: movieID])
            
            if let dict = results as? [String: AnyObject] {
                if let backdrops = dict["backdrops"] as? [[String: AnyObject]] {
                    for backdrop in backdrops {
                        if let image = self.findOrCreateImage(backdrop) {
                            image.movieBackdrop = movie
                        }
                    }
                }
                
                if let posters = dict["posters"] as? [[String: AnyObject]] {
                    for poster in posters {
                        if let image = self.findOrCreateImage(poster) {
                            image.moviePoster = movie
                        }
                    }
                }
                
                CoreDataManager.sharedInstance().saveContext()
            }
            
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: TMDB TV Shows
    func tvShowsOnTheAir(completion: (arrayIDs: [AnyObject]?, error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.TVShows.OnTheAir.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            var tvShowIDs = [NSNumber]()
            
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for tvShow in json {
                        if let m = self.findOrCreateTVShow(tvShow) {
                            tvShowIDs.append(m.tvShowID!)
                        }
                    }
                }
            }
            
            completion(arrayIDs: tvShowIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: nil, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func tvShowsAiringToday(completion: (arrayIDs: [AnyObject]?, error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.TVShows.AiringToday.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            var tvShowIDs = [NSNumber]()
            
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for tvShow in json {
                        if let m = self.findOrCreateTVShow(tvShow) {
                            tvShowIDs.append(m.tvShowID!)
                        }
                    }
                }
            }
            
            completion(arrayIDs: tvShowIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: nil, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: TMDB People
    func peoplePopular(completion: (arrayIDs: [AnyObject]?, error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.People.Popular.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            var personIDs = [NSNumber]()
            
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for person in json {
                        if let m = self.findOrCreatePerson(person) {
                            personIDs.append(m.personID!)
                        }
                    }
                }
            }
            
            completion(arrayIDs: personIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: nil, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: Core Data
    class func sharedInstance() -> TMDBManager {
        
        struct Singleton {
            static var sharedInstance = TMDBManager()
        }
        
        return Singleton.sharedInstance
    }
    
    func findOrCreateMovie(dict: Dictionary<String, AnyObject>) -> Movie? {
        var movie:Movie?
        
        let fetchRequest = NSFetchRequest(entityName: "Movie")
        if let movieID = dict[Movie.Keys.MovieID] as? NSNumber {
            fetchRequest.predicate = NSPredicate(format: "movieID == %@", movieID)
            do {
                if let m = try sharedContext.executeFetchRequest(fetchRequest).first as? Movie {
                    movie = m
                    
                } else {
                    movie = Movie(dictionary: dict, context: sharedContext)
                    
//                    if let tags = dict["tags"] as? String {
//                        if let setTags = findOrCreateTags(tags) {
//                            photo!.tags = setTags
//                        }
//                    }
                    
                    CoreDataManager.sharedInstance().saveContext()
                }
                
            } catch let error as NSError {
                print("Error in fetch \(error), \(error.userInfo)")
            }
        }
        
        return movie
    }
    
    func findOrCreateTVShow(dict: Dictionary<String, AnyObject>) -> TVShow? {
        var tvShow:TVShow?
        
        let fetchRequest = NSFetchRequest(entityName: "TVShow")
        if let tvShowID = dict[TVShow.Keys.TVShowID] as? NSNumber {
            fetchRequest.predicate = NSPredicate(format: "tvShowID == %@", tvShowID)
            do {
                if let m = try sharedContext.executeFetchRequest(fetchRequest).first as? TVShow {
                    tvShow = m
                    
                } else {
                    tvShow = TVShow(dictionary: dict, context: sharedContext)
                    CoreDataManager.sharedInstance().saveContext()
                }
                
            } catch let error as NSError {
                print("Error in fetch \(error), \(error.userInfo)")
            }
        }
        
        return tvShow
    }
    
    func findOrCreatePerson(dict: Dictionary<String, AnyObject>) -> Person? {
        var person:Person?
        
        let fetchRequest = NSFetchRequest(entityName: "Person")
        if let personID = dict[Person.Keys.PersonID] as? NSNumber {
            fetchRequest.predicate = NSPredicate(format: "personID == %@", personID)
            do {
                if let m = try sharedContext.executeFetchRequest(fetchRequest).first as? Person {
                    person = m
                    
                } else {
                    person = Person(dictionary: dict, context: sharedContext)
                    CoreDataManager.sharedInstance().saveContext()
                }
                
            } catch let error as NSError {
                print("Error in fetch \(error), \(error.userInfo)")
            }
        }
        
        return person
    }
    
    func findOrCreateImage(dict: Dictionary<String, AnyObject>) -> Image? {
        var image:Image?
        
        let fetchRequest = NSFetchRequest(entityName: "Image")
        if let filePath = dict[Image.Keys.FilePath] as? String {
            fetchRequest.predicate = NSPredicate(format: "filePath == %@", filePath)
            do {
                if let m = try sharedContext.executeFetchRequest(fetchRequest).first as? Image {
                    image = m
                    
                } else {
                    image = Image(dictionary: dict, context: sharedContext)
                    CoreDataManager.sharedInstance().saveContext()
                }
                
            } catch let error as NSError {
                print("Error in fetch \(error), \(error.userInfo)")
            }
        }
        
        return image
    }
}
