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
    func movieTweets(query: String, completion: (result: AnyObject?, error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": "\(query) movie",
                      "result_type": "mixed"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                completion(result: nil, error: connectionError)
            
            } else {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    completion(result: json, error: connectionError)
                } catch let jsonError as NSError {
                    completion(result: nil, error: jsonError)
                }
            }
        }
    }
    
    func tvShowTweets(query: String, completion: (result: AnyObject?, error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": "\(query) tv",
                      "result_type": "mixed"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                completion(result: nil, error: connectionError)
            
            } else {
            
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    completion(result: json, error: connectionError)
                } catch let jsonError as NSError {
                    completion(result: nil, error: jsonError)
                }
            }
        }
    }
    
    func peopleTweets(query: String, completion: (result: AnyObject?, error: NSError?) -> Void?) throws {
        let client = TWTRAPIClient()
        let endpoint = "https://api.twitter.com/1.1/search/tweets.json"
        let params = ["q": "\(query)",
                      "result_type": "mixed"]
        var clientError : NSError?
        
        let request = client.URLRequestWithMethod("GET", URL: endpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                completion(result: nil, error: connectionError)
                
            } else {
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    completion(result: json, error: connectionError)
                } catch let jsonError as NSError {
                    completion(result: nil, error: jsonError)
                }
            }
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = TwitterManager()
}
