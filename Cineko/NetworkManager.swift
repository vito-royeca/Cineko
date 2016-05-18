//
//  FlickrManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 3/18/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

public enum HTTPMethod : Int {
    case Get
    case Post
    case Delete
    case Put
}

class NetworkManager: NSObject {

    /*!
        @method exec:httpMethod:urlString:headers:parameters:values:body:dataOffset:isJSON:success:failure:
        @abstract Executes an HTTP request
        @param httpMethod the http method i.e GET, POST, @see HttpMethod
        @param urlString the url of the API
        @param headers HTTP headers
        @param parameters HTTP parameters
        @param values HTTP values
        @param body HTTP body
        @param dataOffset size to skip in the HTTP response @see Constants.Parse.DataOffset
        @param isJSON check if response will be parsed as JSON using NSJSONSerialization
        @param success block to handle response data
        @param failure block to handle error message resturned
    */
    func exec(httpMethod: HTTPMethod,
        urlString: String!,
        headers: [String:AnyObject]?,
        parameters: [String:AnyObject]?,
        values: [String:AnyObject]?,
        body: NSData?,
        dataOffset: Int,
        isJSON: Bool,
        success: (results: AnyObject!) -> Void,
        failure: (error: NSError?) -> Void) -> Void {
            
        let components = NSURLComponents(string: urlString)!
        if let parameters = parameters {
            var queryItems = [NSURLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
            
            components.queryItems = queryItems
        }
        
        let request = NSMutableURLRequest(URL: components.URL!)
        
        switch httpMethod {
            case .Get:
                request.HTTPMethod = "GET"
            case .Post:
                request.HTTPMethod = "POST"
            case .Delete:
                request.HTTPMethod = "DELETE"
            case .Put:
                request.HTTPMethod = "PUT"
        }
        
        
        if let headers = headers {
            for (key,value) in headers {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        if let values = values {
            for (key,value) in values {
                request.setValue(value as? String, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.HTTPBody = body
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            var newData: NSData?
            var parsedResult: AnyObject?
            
            guard (error == nil) else {
                if let errorMessage = error?.userInfo[NSLocalizedDescriptionKey] as? String {
                    self.fail(errorMessage, failure: failure)
                } else {
                    self.fail("\(error)", failure: failure)
                }
                
                return
            }
            
            guard let data = data else {
                self.fail("No data was returned by the request!", failure: failure)
                return
            }
            
            if dataOffset > 0 {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            } else {
                newData = data
            }
            
            if isJSON {
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData!, options: .AllowFragments)
                } catch {
                    self.fail("Could not parse the data as JSON.", failure: failure)
                }
            } else {
                parsedResult = newData
            }
            
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let parsedResult = parsedResult {
                    if let errorMessage = parsedResult["error"] as? String {
                        self.fail(errorMessage, failure: failure)
                        
                    } else {
                        self.fail("Your request returned a status code of \((response as? NSHTTPURLResponse)?.statusCode).", failure: failure)
                    }
                } else {
                    self.fail("Your request returned a status code of \((response as? NSHTTPURLResponse)?.statusCode).", failure: failure)
                }
                
                return
            }
            
            success(results: parsedResult)
        }
        
        task.resume()
    }
    
    // MARK: Custom methods
    func fail(error: String, failure: (error: NSError?) -> Void) {
        print(error)
        let userInfo = [NSLocalizedDescriptionKey : error]
        failure(error: NSError(domain: "exec", code: 1, userInfo: userInfo))
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = NetworkManager()
}
