//
//  DownloadManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 04/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
class TMDBManager: NSObject {

    var sessionID:String?

    func requestToken(success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.ApiScheme)://\(Constants.TMDB.ApiHost)\(Constants.TMDBRequestToken.Path)"
        let parameters = Constants.TMDBRequestToken.Parameters
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
    }
    
    func requestSessionID(requestToken: String, success: (results: AnyObject!) -> Void, failure: (error: NSError?) -> Void) {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.ApiScheme)://\(Constants.TMDB.ApiHost)\(Constants.TMDBRequestSessionID.Path)"
        let parameters = [Constants.TMDB.APIKey: Constants.TMDB.APIKeyValue,
                          Constants.TMDBRequestToken.RequestToken: requestToken]
        
        
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
