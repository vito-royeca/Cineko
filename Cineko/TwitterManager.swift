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
    func movieTweets(query: String, completion: (results: [AnyObject], error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": "\"\(query)\"",
                      "result_type": "mixed"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            var array = [AnyObject]()
            
            if connectionError != nil {
                completion(results: array, error: connectionError)
            
            } else {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    if let dict = json as? [String: AnyObject] {
                        if let a = dict["statuses"] as? [AnyObject] {
                            array = a
                        }
                    }
                    
                    completion(results: array, error: connectionError)
                } catch let jsonError as NSError {
                    completion(results: array, error: jsonError)
                }
            }
        }
    }
    
    func tvShowTweets(query: String, completion: (results: [AnyObject], error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": "\"\(query)\"",
                      "result_type": "mixed"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            var array = [AnyObject]()
            
            if connectionError != nil {
                completion(results: array, error: connectionError)
                
            } else {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    if let dict = json as? [String: AnyObject] {
                        if let a = dict["statuses"] as? [AnyObject] {
                            array = a
                        }
                    }
                    
                    completion(results: array, error: connectionError)
                } catch let jsonError as NSError {
                    completion(results: array, error: jsonError)
                }
            }
        }
    }
    
    func personTweets(query: String, completion: (results: [AnyObject], error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/users/search.json"
        let params = ["q": "\(query)",
                      "result_type": "mixed"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            var array = [AnyObject]()
            
            if connectionError != nil {
                completion(results: array, error: connectionError)
                
            } else {
                do {
                    
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    if let dict = json as? [String: AnyObject] {
                        if let a = dict["statuses"] as? [AnyObject] {
                            array = a
                        }
                    }
                    
                    completion(results: array, error: connectionError)
                } catch let jsonError as NSError {
                    completion(results: array, error: jsonError)
                }
            }
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = TwitterManager()
}
