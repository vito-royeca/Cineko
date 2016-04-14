//
//  DownloadManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 14/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

class DatabaseManager: NSObject {
    
    
    // MARK: - Shared Instance
    class func sharedInstance() -> DatabaseManager {
        struct Static {
            static let instance = DatabaseManager()
        }
        
        return Static.instance
    }
}
