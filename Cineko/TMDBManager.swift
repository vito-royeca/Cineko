//
//  TMDBManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 04/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import KeychainAccess

enum TMDBError: ErrorType {
    case NoAPIKey
    case NoSessionID
    case NoAccount
}

struct TMDBConstants {
    static let APIKey          = "api_key"
    static let SessionID       = "session_id"
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
    
    struct Device {
        struct Keys {
            static let RequestToken     = "request_token"
            static let RequestTokenDate = "request_token_date"
            
            static let MoviesNowShowing   = "MoviesNowShowing"
            static let MoviesPopular      = "MoviesPopular"
            static let MoviesTopRated     = "MoviesTopRated"
            static let MoviesComingSoon   = "MoviesComingSoon"
            static let MoviesDynamic      = "MoviesDynamic"
            static let TVShowsAiringToday = "TVShowsAiringToday"
            static let TVShowsPopular     = "TVShowsPopular"
            static let TVShowsTopRated    = "TVShowsTopRated"
            static let TVShowsOnTheAir    = "TVShowsOnTheAir"
            static let TVShowsDynamic     = "TVShowsDymanic"
            static let PeoplePopular      = "PeoplePopular"
            static let FavoriteMovies     = "FavoriteMovies"
            static let FavoriteTVShows    = "FavoriteTVShows"
            static let WatchlistMovies    = "WatchlistMovies"
            static let WatchlistTVShows   = "WatchlistTVShows"
            static let Lists              = "Lists"
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

    struct Account {
        struct Details {
            static let Path = "/account"
        }
        struct Favorite {
            static let Path = "/account/{id}/favorite"
        }
        struct FavoriteMovies {
            static let Path = "/account/{id}/favorite/movies"
        }
        struct FavoriteTVShows {
            static let Path = "/account/{id}/favorite/tv"
        }
        struct Watchlist {
            static let Path = "/account/{id}/watchlist"
        }
        struct WatchlistMovies {
            static let Path = "/account/{id}/watchlist/movies"
        }
        struct WatchlistTVShows {
            static let Path = "/account/{id}/watchlist/tv"
        }
    }

    struct Movies {
        struct NowPlaying {
            static let Path = "/movie/now_playing"
        }
        struct Upcoming {
            static let Path = "/movie/upcoming"
        }
        struct TopRated {
            static let Path = "/movie/top_rated"
        }
        struct Popular {
            static let Path = "/movie/popular"
        }
        struct ByGenre {
            static let Path = "/genre/{id}/movies"
        }
        struct Details {
            static let Path = "/movie/{id}"
        }
        struct Images {
            static let Path = "/movie/{id}/images"
        }
        struct Credits {
            static let Path = "/movie/{id}/credits"
        }
    }
    
    struct TVShows {
        struct OnTheAir {
            static let Path = "/tv/on_the_air"
        }
        struct AiringToday {
            static let Path = "/tv/airing_today"
        }
        struct TopRated {
            static let Path = "/tv/top_rated"
        }
        struct Popular {
            static let Path = "/tv/popular"
        }
        struct Details {
            static let Path = "/tv/{id}"
        }
        struct Images {
            static let Path = "/tv/{id}/images"
        }
        struct Credits {
            static let Path = "/tv/{id}/credits"
        }
    }
    
    struct People {
        struct Popular {
            static let Path = "/person/popular"
        }
        struct Details {
            static let Path = "/person/{id}"
        }
        struct Images {
            static let Path = "/person/{id}/images"
        }
        struct Credits {
            static let Path = "/person/{id}/combined_credits"
        }
    }
    
    struct Genres {
        struct Movie {
            static let Path = "/genre/movie/list"
        }
        struct TVShow {
            static let Path = "/genre/tv/list"
        }
    }
    
    struct Search {
        struct Multi {
            static let Path = "/search/multi"
        }
        struct Movie {
            static let Path = "/search/movie"
        }
        struct TVShow {
            static let Path = "/search/tv"
        }
        struct Person {
            static let Path = "/search/person"
        }
    }
    
    struct Lists {
        struct All {
            static let Path = "/account/{id}/lists"
        }
        struct Details {
            static let Path = "/list/{id}"
        }
        struct Create {
            static let Path = "/list"
        }
        struct Delete {
            static let Path = "/list/{id}"
        }
        struct MovieStatus {
            static let Path = "/list/{id}/item_status"
        }
        struct AddMovie {
            static let Path = "/list/{id}/add_item"
        }
        struct RemoveMovie {
            static let Path = "/list/{id}/remove_item"
        }
    }
}

enum ImageType : Int {
    case MovieBackdrop
    case MoviePoster
    case TVShowBackdrop
    case TVShowPoster
    case PersonProfile
}

enum CreditType : String {
    case Cast = "cast",
         Crew = "crew",
         GuestStar = "guest_star"
}

enum CreditParent : String {
    case Job = "Job",
        Movie = "Movie",
        Person = "Person",
        TVEpisode = "TVEpisode",
        TVSeason = "TVSeason",
        TVShow = "TVShow"
}

enum MediaType : String {
    case Movie = "movie",
        TVShow = "tv",
        Person = "person"
}

let HoursNeededForRefresh = Double(60*60*3) // 3 hours

class TMDBManager: NSObject {
    let keychain = Keychain(server: "\(TMDBConstants.APIURL)", protocolType: .HTTPS)

    // MARK: Variables
    private var apiKey:String?
    var account:Account?
    
    // MARK: Setup
    func setup(apiKey: String) {
        self.apiKey = apiKey
        checkFirstRun()
    }
    
    // MARK: Device
    func checkFirstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("FirstRun") {
            // remove prior keychain items if this is our first run
            keychain[TMDBConstants.SessionID] = nil
            keychain[TMDBConstants.Device.Keys.RequestToken] = nil
            NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.RequestTokenDate)
            
            // then mark this us our first run
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstRun")
        }
    }
    
    func getAvailableRequestToken() throws -> String? {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        if let requestToken = keychain[TMDBConstants.Device.Keys.RequestToken],
            let requestTokenDate = NSUserDefaults.standardUserDefaults().valueForKey(TMDBConstants.Device.Keys.RequestTokenDate) as? NSDate {
            
            // let's calculate the age of the request token
            let interval = requestTokenDate.timeIntervalSinceNow
            let secondsInAnHour:Double = 3600
            let elapsedTime = abs(interval / secondsInAnHour)
            
            // request token's expiration is 1 hour
            if elapsedTime <= 60 {
                return requestToken
            } else {
                logout()
            }
        }
        
        return nil
    }
    
    func saveRequestToken(requestToken: String) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        keychain[TMDBConstants.Device.Keys.RequestToken] = requestToken
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: TMDBConstants.Device.Keys.RequestTokenDate)
    }
    
    func removeRequestToken() throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        keychain[TMDBConstants.Device.Keys.RequestToken] = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.RequestTokenDate)
    }
    
    func saveSessionID(sessionID: String) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        keychain[TMDBConstants.SessionID] = sessionID
    }
    
    func hasSessionID() -> Bool {
        return keychain[TMDBConstants.SessionID] != nil
    }
    
    func needsRefresh(data: String) -> Bool {
        let timeNow = NSDate()
        var needsRefresh = false
        
        if let dataTime = NSUserDefaults.standardUserDefaults().valueForKey(data) as? NSDate {
            if dataTime.timeIntervalSinceNow >= HoursNeededForRefresh {
                needsRefresh = true
            }
            
        } else {
            needsRefresh = true
        }
        
        if needsRefresh {
            NSUserDefaults.standardUserDefaults().setObject(timeNow, forKey: data)
        }
        
        return needsRefresh
    }
    
    func deleteRefreshData(data: String) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(data)
    }
    
    func deleteAllRefreshData() {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.MoviesNowShowing)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.TVShowsAiringToday)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.PeoplePopular)
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.MoviesDynamic)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.MoviesPopular)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.MoviesTopRated)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.MoviesComingSoon)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.FavoriteMovies)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.WatchlistMovies)
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.TVShowsPopular)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.TVShowsTopRated)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.TVShowsOnTheAir)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.TVShowsDynamic)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.FavoriteTVShows)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.WatchlistTVShows)
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.Lists)
    }
    
    func logout() {
        account = nil
        keychain[TMDBConstants.SessionID] = nil
        keychain[TMDBConstants.Device.Keys.RequestToken] = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.RequestTokenDate)
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.FavoriteMovies)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.WatchlistMovies)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.FavoriteTVShows)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.WatchlistTVShows)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    // MARK: Authentication
    func authenticationTokenNew(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Authentication.TokenNew.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func authenticationSessionNew(completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        if let requestToken = try getAvailableRequestToken() {
            let httpMethod:HTTPMethod = .Get
            let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Authentication.SessionNew.Path)"
            let parameters = [TMDBConstants.APIKey: apiKey!,
                              TMDBConstants.Authentication.TokenNew.Keys.RequestToken: requestToken]
            
            let success = { (results: AnyObject!) in
                if let dict = results as? [String: AnyObject] {
                    if let sessionID = dict[TMDBConstants.Authentication.SessionNew.Keys.SessionID] as? String {
                        do {
                            NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.Lists)
                            try self.saveSessionID(sessionID)
                            try self.downloadInitialData(completion)
                        } catch {}
                    }
                }
            }
            
            let failure = { (error: NSError?) -> Void in
                completion(error: error)
            }
            
            NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
        
        } else {
            completion(error: NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey : "No request token available."]))
        }
    }
    
    // MARK: Account
    func downloadInitialData(completion: (error: NSError?) -> Void?) throws {
        // download account details, then favorite movies, then favorite TV shows,
        // then watchlist movies, then watchlist TV shows,
        // then movie genres, then TV show genres
        let accountCompletion = { (error: NSError?) in
            do {
                let fmCompletion =  { (arrayIDs: [AnyObject], error: NSError?) in
                    let ftvCompletion =  { (arrayIDs: [AnyObject], error: NSError?) in
                        let wmCompletion =  { (arrayIDs: [AnyObject], error: NSError?) in
                            let wtvCompletion =  { (arrayIDs: [AnyObject], error: NSError?) in
                                let gMCompletion =  { (arrayIDs: [AnyObject], error: NSError?) in
                                    let gTVCompletion =  { (arrayIDs: [AnyObject], error: NSError?) in
                                        completion(error: error)
                                    }
                                    do {
                                        try self.genresTVShow(gTVCompletion)
                                    } catch {}
                                }
                                do {
                                    try self.genresMovie(gMCompletion)
                                } catch {}
                            }
                            do {
                                try self.accountWatchlistTVShows(wtvCompletion)
                            } catch {}
                        }
                        do {
                            try self.accountWatchlistMovies(wmCompletion)
                        } catch {}
                    }
                    do {
                        try self.accountFavoriteTVShows(ftvCompletion)
                    } catch {}
                }
                try self.accountFavoriteMovies(fmCompletion)
            } catch {}
        }
        do {
            try accountDetails(accountCompletion)
        } catch {
            // down load movie and TV genres even if User did not log in
            let gMCompletion =  { (arrayIDs: [AnyObject], error: NSError?) in
                let gTVCompletion =  { (arrayIDs: [AnyObject], error: NSError?) in
                    completion(error: error)
                }
                do {
                    try self.genresTVShow(gTVCompletion)
                } catch {}
            }
            do {
                try self.genresMovie(gMCompletion)
            } catch {}
        }
    }
    
    func accountDetails(completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }

        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Account.Details.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                self.account = ObjectManager.sharedInstance().findOrCreateAccount(dict)
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func accountFavorite(mediaID: NSNumber, mediaType: MediaType, favorite: Bool, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Post
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Account.Favorite.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(account!.accountID!)")
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/json"]
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        
        let bodyDict = ["media_type": mediaType.rawValue,
                        "media_id": "\(mediaID)",
                        "favorite": favorite]
        let body = try NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted)
        
        let success = { (results: AnyObject!) -> Void in
            switch mediaType {
            case .Movie:
                let movie = ObjectManager.sharedInstance().findOrCreateMovie([Movie.Keys.MovieID: mediaID])
                movie.favorite = NSNumber(bool: favorite)
            case .TVShow:
                let tvShow = ObjectManager.sharedInstance().findOrCreateTVShow([TVShow.Keys.TVShowID: mediaID])
                tvShow.favorite = NSNumber(bool: favorite)
            default:
                break
            }
            CoreDataManager.sharedInstance().savePrivateContext()
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: headers, parameters: parameters, values: nil, body: body, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func accountWatchlist(mediaID: NSNumber, mediaType: MediaType, watchlist: Bool, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Post
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Account.Watchlist.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(account!.accountID!)")
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/json"]
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        
        let bodyDict = ["media_type": mediaType.rawValue,
                        "media_id": "\(mediaID)",
                        "watchlist": watchlist]
        let body = try NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted)
        
        let success = { (results: AnyObject!) -> Void in
            switch mediaType {
            case .Movie:
                let movie = ObjectManager.sharedInstance().findOrCreateMovie([Movie.Keys.MovieID: mediaID])
                movie.watchlist = NSNumber(bool: watchlist)
            case .TVShow:
                let tvShow = ObjectManager.sharedInstance().findOrCreateTVShow([TVShow.Keys.TVShowID: mediaID])
                tvShow.watchlist = NSNumber(bool: watchlist)
            default:
                break
            }
            CoreDataManager.sharedInstance().savePrivateContext()
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: headers, parameters: parameters, values: nil, body: body, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func accountFavoriteMovies(completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Account.FavoriteMovies.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(account!.accountID!)")
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        var movieIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    
                    for movie in json {
                        let m = ObjectManager.sharedInstance().findOrCreateMovie(movie)
                        m.favorite = NSNumber(bool: true)
                        CoreDataManager.sharedInstance().savePrivateContext()
                        
                        if let movieID = m.movieID {
                            movieIDs.append(movieID)
                        }
                    }
                }
            }
            completion(arrayIDs: movieIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: movieIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func accountFavoriteTVShows(completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Account.FavoriteTVShows.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(account!.accountID!)")
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        var tvShowIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    
                    for tvShow in json {
                        let m = ObjectManager.sharedInstance().findOrCreateTVShow(tvShow)
                        m.favorite = NSNumber(bool: true)
                        CoreDataManager.sharedInstance().savePrivateContext()
                        
                        if let tvShowID = m.tvShowID {
                            tvShowIDs.append(tvShowID)
                        }
                    }
                }
            }
            completion(arrayIDs: tvShowIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: tvShowIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func accountWatchlistMovies(completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Account.WatchlistMovies.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(account!.accountID!)")
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        var movieIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    
                    for movie in json {
                        let m = ObjectManager.sharedInstance().findOrCreateMovie(movie)
                        m.watchlist = NSNumber(bool: true)
                        CoreDataManager.sharedInstance().savePrivateContext()
                        
                        if let movieID = m.movieID {
                            movieIDs.append(movieID)
                        }
                    }
                }
            }
            completion(arrayIDs: movieIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: movieIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func accountWatchlistTVShows(completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Account.WatchlistTVShows.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(account!.accountID!)")
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        var tvShowIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    
                    for tvShow in json {
                        let m = ObjectManager.sharedInstance().findOrCreateTVShow(tvShow)
                        m.watchlist = NSNumber(bool: true)
                        CoreDataManager.sharedInstance().savePrivateContext()
                        
                        if let tvShowID = m.tvShowID {
                            tvShowIDs.append(tvShowID)
                        }
                    }
                }
            }
            completion(arrayIDs: tvShowIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: tvShowIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: Movies
    func movies(path: String, completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        var movieIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for movie in json {
                        let m = ObjectManager.sharedInstance().findOrCreateMovie(movie)
                        if let movieID = m.movieID {
                            movieIDs.append(movieID)
                        }
                    }
                }
            }
            completion(arrayIDs: movieIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: movieIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    func moviesByGenre(genreID: Int, completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Movies.ByGenre.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(genreID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        var movieIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for movie in json {
                        let m = ObjectManager.sharedInstance().findOrCreateMovie(movie)
                        if let movieID = m.movieID {
                            movieIDs.append(movieID)
                        }
                    }
                }
            }
            completion(arrayIDs: movieIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: movieIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    func movieDetails(movieID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Movies.Details.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(movieID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
    
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let title = dict[Movie.Keys.Title] as? String {
              
                    let comp2 = { (objectIDs: [AnyObject], error: NSError?) in
                        ObjectManager.sharedInstance().updateMovie(dict, reviewIDs: objectIDs)
                        completion(error: nil)
                    }
                    
                    do {
                        try NYTimesReviewManager.sharedInstance().movieReviews(title, completion: comp2)
                    } catch {
                        completion(error: nil)
                    }
                }
            }
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    func movieImages(movieID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Movies.Images.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(movieID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            let movie = ObjectManager.sharedInstance().findOrCreateMovie([Movie.Keys.MovieID: movieID])
            
            if let dict = results as? [String: AnyObject] {
                if let backdrops = dict["backdrops"] as? [[String: AnyObject]] {
                    for backdrop in backdrops {
                        ObjectManager.sharedInstance().findOrCreateImage(backdrop, imageType: .MovieBackdrop, forObject: movie)
                    }
                }
                
                if let posters = dict["posters"] as? [[String: AnyObject]] {
                    for poster in posters {
                        ObjectManager.sharedInstance().findOrCreateImage(poster, imageType: .MoviePoster, forObject: movie)
                    }
                }
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    func movieCredits(movieID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Movies.Credits.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(movieID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            let movie = ObjectManager.sharedInstance().findOrCreateMovie([Movie.Keys.MovieID: movieID])
            
            if let dict = results as? [String: AnyObject] {
                if let cast = dict["cast"] as? [[String: AnyObject]] {
                    for c in cast {
                        ObjectManager.sharedInstance().findOrCreateCredit(c, creditType: .Cast, creditParent: .Movie, forObject: movie)
                    }
                }
                
                if let crew = dict["crew"] as? [[String: AnyObject]] {
                    for c in crew {
                        ObjectManager.sharedInstance().findOrCreateCredit(c, creditType: .Crew, creditParent: .Movie, forObject: movie)
                    }
                }
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: TV Shows
    func tvShows(path: String, completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        var tvShowIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for tvShow in json {
                        let m = ObjectManager.sharedInstance().findOrCreateTVShow(tvShow)
                        if let tvShowID = m.tvShowID {
                            tvShowIDs.append(tvShowID)
                        }
                    }
                }
            }
            completion(arrayIDs: tvShowIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: tvShowIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    func tvShowDetails(tvShowID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.TVShows.Details.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(tvShowID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                ObjectManager.sharedInstance().updateTVShow(dict)
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    func tvShowImages(tvShowID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.TVShows.Images.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(tvShowID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            let tvShow = ObjectManager.sharedInstance().findOrCreateTVShow([TVShow.Keys.TVShowID: tvShowID])
            
            if let dict = results as? [String: AnyObject] {
                if let backdrops = dict["backdrops"] as? [[String: AnyObject]] {
                    for backdrop in backdrops {
                        ObjectManager.sharedInstance().findOrCreateImage(backdrop, imageType: .TVShowBackdrop, forObject: tvShow)
                    }
                }
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    func tvShowCredits(tvShowID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.TVShows.Credits.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(tvShowID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            let tvShow = ObjectManager.sharedInstance().findOrCreateTVShow([TVShow.Keys.TVShowID: tvShowID])
            
            if let dict = results as? [String: AnyObject] {
                if let cast = dict["cast"] as? [[String: AnyObject]] {
                    for c in cast {
                        ObjectManager.sharedInstance().findOrCreateCredit(c, creditType: .Cast, creditParent: .TVShow, forObject: tvShow)
                    }
                }
                
                if let crew = dict["crew"] as? [[String: AnyObject]] {
                    for c in crew {
                        ObjectManager.sharedInstance().findOrCreateCredit(c, creditType: .Crew, creditParent: .TVShow, forObject: tvShow)
                    }
                }
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: People
    func peoplePopular(completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.People.Popular.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        var personIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for person in json {
                        let m = ObjectManager.sharedInstance().findOrCreatePerson(person)
                        if let personID = m.personID {
                            personIDs.append(personID)
                        }
                    }
                }
            }
            completion(arrayIDs: personIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: personIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func personDetails(personID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.People.Details.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(personID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                ObjectManager.sharedInstance().updatePerson(dict)
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func personImages(personID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.People.Images.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(personID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            let person = ObjectManager.sharedInstance().findOrCreatePerson([Person.Keys.PersonID: personID])
            
            if let dict = results as? [String: AnyObject] {
                if let profiles = dict["profiles"] as? [[String: AnyObject]] {
                    for profile in profiles {
                        ObjectManager.sharedInstance().findOrCreateImage(profile, imageType: .PersonProfile, forObject: person)
                    }
                }
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func personCredits(personID: NSNumber, completion: (error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.People.Credits.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(personID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        
        let success = { (results: AnyObject!) in
            let person = ObjectManager.sharedInstance().findOrCreatePerson([Person.Keys.PersonID: personID])
            
            if let dict = results as? [String: AnyObject] {
                if let cast = dict["cast"] as? [[String: AnyObject]] {
                    for c in cast {
                        ObjectManager.sharedInstance().findOrCreateCredit(c, creditType: .Cast, creditParent: .Person, forObject: person)
                    }
                }
                
                if let crew = dict["crew"] as? [[String: AnyObject]] {
                    for c in crew {
                        ObjectManager.sharedInstance().findOrCreateCredit(c, creditType: .Crew, creditParent: .Person, forObject: person)
                    }
                }
            }
            completion(error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: Genre
    func genresMovie(completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Genres.Movie.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        var genreIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["genres"] as? [[String: AnyObject]] {
                    for genre in json {
                        let m = ObjectManager.sharedInstance().findOrCreateGenre(genre)
                        if let genreID = m.genreID {
                            genreIDs.append(genreID)
                        }
                        m.movieGenre = NSNumber(bool: true)
                    }
                }
            }
            CoreDataManager.sharedInstance().savePrivateContext()
            completion(arrayIDs: genreIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: genreIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func genresTVShow(completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Genres.Movie.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!]
        var genreIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["genres"] as? [[String: AnyObject]] {
                    for genre in json {
                        let m = ObjectManager.sharedInstance().findOrCreateGenre(genre)
                        if let genreID = m.genreID {
                            genreIDs.append(genreID)
                        }
                        m.tvGenre = NSNumber(bool: true)
                    }
                }
            }
            CoreDataManager.sharedInstance().savePrivateContext()
            completion(arrayIDs: genreIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: genreIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: Search
    func searchMulti(query: String, completion: (results: [MediaType: [AnyObject]], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Search.Multi.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          "query": query,
                          "include_adult": "true"]
        
        var media = [MediaType: [AnyObject]]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for dict in json {
                        if let mediaType = dict["media_type"] as? String {
                            var ids:[NSNumber]?
                            
                            if mediaType == "movie" {
                                let m = ObjectManager.sharedInstance().findOrCreateMovie(dict)
                                if let movieID = m.movieID {
                                    if let x = media[MediaType.Movie] as? [NSNumber] {
                                        ids = x
                                    } else {
                                        ids = [NSNumber]()
                                    }
                                    ids!.append(movieID)
                                    media[MediaType.Movie] = ids
                                }
                            } else if mediaType == "tv" {
                                let m = ObjectManager.sharedInstance().findOrCreateTVShow(dict)
                                if let tvShowID = m.tvShowID {
                                    if let x = media[MediaType.TVShow] as? [NSNumber] {
                                        ids = x
                                    } else {
                                        ids = [NSNumber]()
                                    }
                                    ids!.append(tvShowID)
                                    media[MediaType.TVShow] = ids
                                }
                            } else if mediaType == "person" {
                                let m = ObjectManager.sharedInstance().findOrCreatePerson(dict)
                                if let personID = m.personID {
                                    if let x = media[MediaType.Person] as? [NSNumber] {
                                        ids = x
                                    } else {
                                        ids = [NSNumber]()
                                    }
                                    ids!.append(personID)
                                    media[MediaType.Person] = ids
                                }
                            }
                        }
                    }
                }
            }
        
            completion(results: media, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(results: media, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func searchMovie(query: String, releaseYear year: Int, includeAdult: Bool, completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Search.Movie.Path)"
        var parameters = [TMDBConstants.APIKey: apiKey!,
                          "query": query,
                          "include_adult": "\(includeAdult)"]
        if year > 0 {
            parameters["year"] = "\(year)"
        }
        
        var array = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for dict in json {
                        
                        let m = ObjectManager.sharedInstance().findOrCreateMovie(dict)
                        if let movieID = m.movieID {
                            array.append(movieID)
                        }
                    }
                }
            }
            
            completion(arrayIDs: array, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: array, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func searchTVShow(query: String, firstAirDate year: Int, completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Search.TVShow.Path)"
        var parameters = [TMDBConstants.APIKey: apiKey!,
                          "query": query]
        if year > 0 {
            parameters["first_air_date_year"] = "\(year)"
        }
        
        var array = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for dict in json {
                        
                        let m = ObjectManager.sharedInstance().findOrCreateTVShow(dict)
                        if let tvShowID = m.tvShowID {
                            array.append(tvShowID)
                        }
                    }
                }
            }
            
            completion(arrayIDs: array, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: array, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func searchPeople(query: String, includeAdult: Bool, completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Search.Person.Path)"
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          "query": query,
                          "include_adult": "\(includeAdult)"]
        
        var array = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for dict in json {
                        
                        let m = ObjectManager.sharedInstance().findOrCreatePerson(dict)
                        if let personID = m.personID {
                            array.append(personID)
                        }
                    }
                }
            }
            
            completion(arrayIDs: array, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: array, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    // MARK: Lists
    func lists(completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }

        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Lists.All.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(account!.accountID!)")
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        var listIDs = [String]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["results"] as? [[String: AnyObject]] {
                    for list in json {
                        let m = ObjectManager.sharedInstance().findOrCreateList(list)
                        m.createdBy = self.account
                        
                        if let listID = m.listID {
                            listIDs.append(listID)
                        }
                    }
                }
            }
            CoreDataManager.sharedInstance().savePrivateContext()
            completion(arrayIDs: listIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: listIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func listDetails(listID: String, completion: (arrayIDs: [AnyObject], error: NSError?) -> Void?) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Lists.Details.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(listID)")
        let parameters = [TMDBConstants.APIKey: apiKey!]
        var movieIDs = [NSNumber]()
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let json = dict["items"] as? [[String: AnyObject]] {
                    for movie in json {
                        let m = ObjectManager.sharedInstance().findOrCreateMovie(movie)
                        if let movieID = m.movieID {
                            movieIDs.append(movieID)
                        }
                    }
                }
            }
            completion(arrayIDs: movieIDs, error: nil)
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(arrayIDs: movieIDs, error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func createList(name: String, description: String, completion: (error: NSError?) -> Void) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Post
        let urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Lists.Create.Path)"
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/json"]
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        let bodyDict = ["name": name,
                        "description": description]
        let body = try NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted)
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let _ = dict["list_id"] {
                    
                    // force refresh of Lists
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.Lists)
                    completion(error: nil)
                } else {
                    let e = NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error creating list: \(name)."])
                    completion(error: e)
                }
            }
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: headers, parameters: parameters, values: nil, body: body, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func deleteList(listID: String, completion: (error: NSError?) -> Void) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Delete
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Lists.Delete.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: listID)
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let statusCode = dict["status_code"] as? Int {
                    if statusCode == 13 { // 13 	200 	The item/record was deleted successfully.
                        // force refresh of Lists
                        NSUserDefaults.standardUserDefaults().removeObjectForKey(TMDBConstants.Device.Keys.Lists)
                        
                        ObjectManager.sharedInstance().deleteObject("List", objectKey: "listID", objectValue: listID)
                        
                        completion(error: nil)
                    } else {
                        let e = NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error deleting list: \(listID)."])
                        completion(error: e)
                    }
                } else {
                    let e = NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error deleting list: \(listID)."])
                    completion(error: e)
                }
            }
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }

    func addMovie(movieID: NSNumber, toList listID: String, completion: (error: NSError?) -> Void) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Post
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Lists.AddMovie.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: listID)
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/json"]
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        let bodyDict = ["media_id": movieID]
        let body = try NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted)
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let statusCode = dict["status_code"] as? Int {
                    if statusCode == 12 { // 12 	201 	The item/record was updated successfully.
                        let list = ObjectManager.sharedInstance().findOrCreateList([List.Keys.ListID: listID])
                        let movie = ObjectManager.sharedInstance().findOrCreateMovie([Movie.Keys.MovieID: movieID])
                        let movies = list.mutableSetValueForKey("movies")
                        movies.addObject(movie)
                        CoreDataManager.sharedInstance().savePrivateContext()
                        
                        completion(error: nil)
                    } else {
                        let e = NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error adding movie to list"])
                        completion(error: e)
                    }
                } else {
                    let e = NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error adding movie to list"])
                    completion(error: e)
                }
            }
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: headers, parameters: parameters, values: nil, body: body, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func removeMovie(movieID: NSNumber, fromList listID: String, completion: (error: NSError?) -> Void) throws {
        guard (apiKey) != nil else {
            throw TMDBError.NoAPIKey
        }
        
        guard hasSessionID() else {
            throw TMDBError.NoSessionID
        }
        
        guard account != nil else {
            throw TMDBError.NoAccount
        }
        
        let httpMethod:HTTPMethod = .Post
        var urlString = "\(TMDBConstants.APIURL)\(TMDBConstants.Lists.RemoveMovie.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: listID)
        let headers = ["Accept": "application/json",
                       "Content-Type": "application/json"]
        let parameters = [TMDBConstants.APIKey: apiKey!,
                          TMDBConstants.SessionID: keychain[TMDBConstants.SessionID]!]
        let bodyDict = ["media_id": movieID]
        let body = try NSJSONSerialization.dataWithJSONObject(bodyDict, options: .PrettyPrinted)

        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                if let statusCode = dict["status_code"] as? Int {
                    if statusCode == 13 { // 13 	200 	The item/record was deleted successfully.
                        let list = ObjectManager.sharedInstance().findOrCreateList([List.Keys.ListID: listID])
                        let movie = ObjectManager.sharedInstance().findOrCreateMovie([Movie.Keys.MovieID: movieID])
                        let movies = list.mutableSetValueForKey("movies")
                        movies.removeObject(movie)
                        CoreDataManager.sharedInstance().savePrivateContext()
                        
                        completion(error: nil)
                    } else {
                        let e = NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error removing movie to list"])
                        completion(error: e)
                    }
                } else {
                    let e = NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error adding movie to list"])
                    completion(error: e)
                }
            }
        }
        
        let failure = { (error: NSError?) -> Void in
            completion(error: error)
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: headers, parameters: parameters, values: nil, body: body, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> TMDBManager {
        
        struct Singleton {
            static var sharedInstance = TMDBManager()
        }
        
        return Singleton.sharedInstance
    }
}
