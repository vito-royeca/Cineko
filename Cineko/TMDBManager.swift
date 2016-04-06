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
    let keychain = Keychain(server: "\(Constants.TMDB.ApiScheme)://\(Constants.TMDB.ApiHost)", protocolType: .HTTPS)

    func checkFirstRun() {
        if !NSUserDefaults.standardUserDefaults().boolForKey("FirstRun") {
            // remove prior keychain items if this is our first run
            TMDBManager.sharedInstance().keychain[Constants.TMDB.SessionIDKey] = nil
            TMDBManager.sharedInstance().keychain[Constants.TMDB.RequestTokenKey] = nil
            NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.TMDB.RequestTokenDate)
            
            // then mark this us our first run
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstRun")
        }
    }
    
    func requestToken(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.ApiScheme)://\(Constants.TMDB.ApiHost)\(Constants.TMDBRequestToken.Path)"
        let parameters = Constants.TMDBRequestToken.Parameters
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func requestSessionID(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        if let requestToken = getAvailableRequestToken() {
            let httpMethod:HTTPMethod = .Get
            let urlString = "\(Constants.TMDB.ApiScheme)://\(Constants.TMDB.ApiHost)\(Constants.TMDBRequestSessionID.Path)"
            let parameters = [Constants.TMDB.APIKey: Constants.TMDB.APIKeyValue,
                              Constants.TMDBRequestToken.RequestToken: requestToken]
            
            NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
        
        } else {
            failure(error: NSError(domain: "exec", code: 1, userInfo: [NSLocalizedDescriptionKey : "No request token available."]))
        }
    }
    
    func getAvailableRequestToken() -> String? {
        if let requestToken = keychain[Constants.TMDB.RequestTokenKey],
            let requestTokenDate = NSUserDefaults.standardUserDefaults().valueForKey(Constants.TMDB.RequestTokenDate) as? NSDate {
            
            // let's calculate the age of the request token
            let interval = requestTokenDate.timeIntervalSinceNow
            let secondsInAnHour:Double = 3600
            let elapsedTime = abs(interval / secondsInAnHour)
            
            // request token's expiration is 1 hour
            if elapsedTime <= 60 {
                return requestToken
            }
        }
        
        return nil
    }
    
    func saveRequestToken(requestToken: String) {
        TMDBManager.sharedInstance().keychain[Constants.TMDB.RequestTokenKey] = requestToken
        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: Constants.TMDB.RequestTokenDate)
    }
    
    func removeRequestToken() {
        TMDBManager.sharedInstance().keychain[Constants.TMDB.RequestTokenKey] = nil
        NSUserDefaults.standardUserDefaults().removeObjectForKey(Constants.TMDB.RequestTokenDate)
    }
    
    func saveSessionID(sessionID: String) {
        TMDBManager.sharedInstance().keychain[Constants.TMDB.SessionIDKey] = sessionID
    }
    
    // MARK: - Shared Instance
    class func sharedInstance() -> TMDBManager {
        
        struct Singleton {
            static var sharedInstance = TMDBManager()
        }
        
        return Singleton.sharedInstance
    }
}
