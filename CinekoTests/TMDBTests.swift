//
//  TMDBTests.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import XCTest

class TMDBTests: XCTestCase {
    
    var finished = false
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let httpMethod:HTTPMethod = .Get
        let urlString = "\(Constants.TMDB.ApiScheme)://\(Constants.TMDB.ApiHost)"
        let parameters = [
            Constants.TMDB.APIKey: Constants.TMDB.APIKeyValue
        ]
        
        let success = { (results: AnyObject!) in
            if let dict = results as? [String: AnyObject] {
                print("\(dict)")
                self.finished = true
                
//                if let photos = dict["photos"] as? [String: AnyObject] {
//                    if let photo = photos["photo"] as? [[String: AnyObject]] {
//                        print("\(photo)")
//                        
//                        for d in photo {
//                            if let p = self.findOrCreatePhoto(d, pin: pin!) {
//                                self.downloadPhotoImage(p)
//                            }
//                        }
//                        
//                    }  else {
//                        print("error: photo key not found")
//                    }
//                } else {
//                    print("error: photos key not found")
//                }
            }
        }
        
        let failure = { (error: NSError?) in
            print("error=\(error)")
            self.finished = true
        }
        
        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
        
        repeat {
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate:NSDate.distantFuture())
        } while !finished
    }
    
}
