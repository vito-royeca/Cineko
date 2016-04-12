//
//  TMDBManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 04/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import KeychainAccess

class TMDBManager: NSObject {
    let keychain = Keychain(server: "\(Constants.TMDB.APIURL)", protocolType: .HTTPS)

    // MARK: iPad
    func checkFirstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("FirstRun") {
            // remove prior keychain items if this is our first run
            TMDBManager.sharedInstance().keychain[Constants.TMDB.iPad.Keys.SessionID] = nil
            TMDBManager.sharedInstance().keychain[Constants.TMDB.iPad.Keys.RequestToken] = nil
            NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.TMDB.iPad.Keys.RequestTokenDate)
            
            // then mark this us our first run
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstRun")
        }
    }
    
    func getAvailableRequestToken() -> String? {
        if let requestToken = keychain[Constants.TMDB.iPad.Keys.RequestToken],
            let requestTokenDate = NSUserDefaults.standardUserDefaults().valueForKey(Constants.TMDB.iPad.Keys.RequestTokenDate) as? NSDate {
            
            // let's calculate the age of the request token
            let interval = requestTokenDate.timeIntervalSinceNow
            let secondsInAnHour:Double = 3600
            let elapsedTime = abs(interval / secondsInAnHour)
            
            // request token's expiration is 1 hour
            if elapsedTime <= 60 {
                return requestToken
                
            } else {
                TMDBManager.sharedInstance().keychain[Constants.TMDB.iPad.Keys.SessionID] = nil
                TMDBManager.sharedInstance().keychain[Constants.TMDB.iPad.Keys.RequestToken] = nil
                NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.TMDB.iPad.Keys.RequestTokenDate)
            }
        }
        
        return nil
    }
    
    func saveRequestToken(requestToken: String) {
        TMDBManager.sharedInstance().keychain[Constants.TMDB.iPad.Keys.RequestToken] = requestToken
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Constants.TMDB.iPad.Keys.RequestTokenDate)
    }
    
    func removeRequestToken() {
        TMDBManager.sharedInstance().keychain[Constants.TMDB.iPad.Keys.RequestToken] = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.TMDB.iPad.Keys.RequestTokenDate)
    }
    
    func saveSessionID(sessionID: String) {
        TMDBManager.sharedInstance().keychain[Constants.TMDB.iPad.Keys.SessionID] = sessionID
    }
    
    // MARK: TMDB Authentication
    func authenticationTokenNew(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.APIURL)\(Constants.TMDB.Authentication.TokenNew.Path)"
        let parameters = Constants.TMDB.Parameters
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func authenticationSessionNew(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        if let requestToken = getAvailableRequestToken() {
            let httpMethod:HTTPMethod = .Get
            let urlString = "\(Constants.TMDB.APIURL)\(Constants.TMDB.Authentication.SessionNew.Path)"
            let parameters = [Constants.TMDB.APIKey: Constants.TMDB.APIKeyValue,
                              Constants.TMDB.Authentication.TokenNew.Keys.RequestToken: requestToken]
            
            NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
        
        } else {
            failure(error: NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey : "No request token available."]))
        }
    }
    
    // MARK: TMDB Movies
    func moviesNowPlaying(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.APIURL)\(Constants.TMDB.Movies.NowPlaying.Path)"
        let parameters = Constants.TMDB.Parameters
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func moviesID(movieID: NSNumber, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        var urlString = "\(Constants.TMDB.APIURL)\(Constants.TMDB.Movies.ID.Path)"
        urlString = urlString.stringByReplacingOccurrencesOfString("{id}", withString: "\(movieID)")
        let parameters = Constants.TMDB.Parameters
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: TMDB TV Shows
    func tvShowsOnTheAir(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.APIURL)\(Constants.TMDB.TVShows.OnTheAir.Path)"
        let parameters = Constants.TMDB.Parameters
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func tvShowsAiringToday(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.APIURL)\(Constants.TMDB.TVShows.AiringToday.Path)"
        let parameters = Constants.TMDB.Parameters
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: TMDB People
    func peoplePopular(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.APIURL)\(Constants.TMDB.People.Popular.Path)"
        let parameters = Constants.TMDB.Parameters
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> TMDBManager {
        
        struct Singleton {
            static var sharedInstance = TMDBManager()
        }
        
        return Singleton.sharedInstance
    }
}
