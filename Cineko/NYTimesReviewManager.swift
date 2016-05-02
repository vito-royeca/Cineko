//
//  NYTimesReviewManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/05/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class NYTimesReviewManager: NSObject {
    // MARK: Variables
    private var apiKey:String?
    
    // MARK: Setup
    func setup(apiKey: String) {
        self.apiKey = apiKey
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> NYTimesReviewManager {
        
        struct Singleton {
            static var sharedInstance = NYTimesReviewManager()
        }
        
        return Singleton.sharedInstance
    }
}
