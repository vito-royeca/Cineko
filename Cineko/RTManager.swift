//
//  RTManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 14/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

enum RTError: ErrorType {
    case NoAPIKey
    case NoSessionID
}

struct TRConstants {
    static let APIKey     = "api_key"
    static let APIURL     = "hapi.rottentomatoes.com/api/public/v1.0.json"
    
}

class RTManager: NSObject {
    // MARK: Variables
    private var apiKey:String?
    
    // MARK: Setup
    func setup(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = RTManager()
}
