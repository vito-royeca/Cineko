//
//  TwitterManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 18/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterManager: NSObject {
    func userSearch(query: String, completion: (results: [AnyObject], error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/users/search.json"
        let params = ["q": "\(query)"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            let arrResults = [AnyObject]()
            
            if connectionError != nil {
                completion(results: arrResults, error: connectionError)
                
            } else {
                do {
                    var screenName:String?
                    var followersCount = 0
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    
                    if let array = json as? [[String: AnyObject]] {
                        for dict in array {
                            // get a verified or the most popular user
                            if let verified = dict["verified"] as? Bool {
                                if verified {
                                    screenName = dict["screen_name"] as? String
                                    break
                                    
                                } else {
                                    if let count = dict["followers_count"] as? Int {
                                        if count > followersCount {
                                            screenName = dict["screen_name"] as? String
                                        }
                                        followersCount = count
                                    }
                                }
                            } else {
                                if let count = dict["followers_count"] as? Int {
                                    if count > followersCount {
                                        screenName = dict["screen_name"] as? String
                                    }
                                    followersCount = count
                                }
                            }
                        }
                    }
                    
                    if let screenName = screenName {
                        do {
                            try self.userTimeline(screenName, completion: completion)
                        } catch {
                            completion(results: arrResults, error: connectionError)
                        }
                    
                    } else {
                        do {
                            try self.searchTweets("\(query)", completion: completion)
                        } catch {
                            completion(results: arrResults, error: connectionError)
                        }
                    }
                } catch let jsonError as NSError {
                    completion(results: arrResults, error: jsonError)
                }
            }
        }
    }
    
    func searchTweets(query: String, completion: (results: [AnyObject], error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": "\(query)",
                      "result_type": "mixed"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            var arrResults = [AnyObject]()
            
            if connectionError != nil {
                completion(results: arrResults, error: connectionError)
                
            } else {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    if let dict = json as? [String: AnyObject] {
                        if let a = dict["statuses"] as? [AnyObject] {
                            arrResults = a
                        }
                    }
                    
                    completion(results: arrResults, error: connectionError)
                } catch let jsonError as NSError {
                    completion(results: arrResults, error: jsonError)
                }
            }
        }
    }
    
    func userTimeline(screenName: String, completion: (results: [AnyObject], error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/statuses/user_timeline.json"
        let params = ["screen_name": "\(screenName)"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            var arrResults = [AnyObject]()
            
            if connectionError != nil {
                completion(results: arrResults, error: connectionError)
                
            } else {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    if let dict = json as? [[String: AnyObject]] {
                        arrResults = dict
                    }
                    
                    completion(results: arrResults, error: connectionError)
                } catch let jsonError as NSError {
                    completion(results: arrResults, error: jsonError)
                }
            }
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = TwitterManager()
}
