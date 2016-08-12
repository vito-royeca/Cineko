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
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
//    func testCredits() {
//        let creditID = "52fe4d5bc3a368484e1e4c55"
//        
//        let httpMethod:HTTPMethod = .Get
//        let urlString = "\(TMDBConstants.APIURL)/credit/\(creditID)"
//        let parameters = [TMDBConstants.APIKey: Constants.TMDBAPIKeyValue]
//        
//        let success = { (results: AnyObject!) in
//            if let dict = results as? [String: AnyObject] {
//                print("json=\(dict)")
//            }
//            
//            self.finished = true
//        }
//        
//        let failure = { (error: NSError?) -> Void in
//            print("error: \(error!)")
//            self.finished = true
//        }
//        
//        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
//        
//        repeat {
//            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate:NSDate.distantFuture())
//        } while !finished
//    }
//    
//    func testMovieDetails() {
//        let movieID = "209112"
//        
//        let httpMethod:HTTPMethod = .Get
//        let urlString = "\(TMDBConstants.APIURL)/movie/\(movieID)"
//        let parameters = [TMDBConstants.APIKey: Constants.TMDBAPIKeyValue]
//        
//        let success = { (results: AnyObject!) in
//            if let dict = results as? [String: AnyObject] {
//                print("json=\(dict)")
//            }
//            
//            self.finished = true
//        }
//        
//        let failure = { (error: NSError?) -> Void in
//            print("error: \(error!)")
//            self.finished = true
//        }
//        
//        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
//        
//        repeat {
//            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate:NSDate.distantFuture())
//        } while !finished
//    }
//    
//    func testDownloadInitialData() {
//        CoreDataManager.sharedInstance().setup(Constants.CoreDataSQLiteFile, modelFile: Constants.CoreDataModelFile)
//        
//        let httpMethod:HTTPMethod = .Get
//        let urlString = "\(TMDBConstants.APIURL)/job/list"
//        let parameters = [TMDBConstants.APIKey: Constants.TMDBAPIKeyValue]
//        
//        let success = { (results: AnyObject!) in
//            if let dict = results as? [String: AnyObject] {
//                if let jobs = dict["jobs"] as? [[String: AnyObject]] {
//                    for job in jobs {
//                        
//                        if let department = job["department"] as? String,
//                            let lists = job["job_list"] as? [String] {
//                            
//                            for list in lists {
//                                let d = ["name": list, "department": department]
//                                ObjectManager.sharedInstance().findOrCreateJob(d)
//                            }
//                        }
//                        
//                    }
//                }
//                
////                self.downloadGenres()
//                self.finished = true
//            }
//        }
//        
//        let failure = { (error: NSError?) -> Void in
//            print("error: \(error!)")
//            self.finished = true
//        }
//        
//        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
//        
//        repeat {
//            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate:NSDate.distantFuture())
//        } while !finished
//    }
//    
//    func downloadGenres() {
//        let httpMethod:HTTPMethod = .Get
//        let urlString = "\(TMDBConstants.APIURL)/job/list"
//        let parameters = [TMDBConstants.APIKey: Constants.TMDBAPIKeyValue]
//        
//        let success = { (results: AnyObject!) in
//            if let dict = results as? [String: AnyObject] {
//                if let jobs = dict["jobs"] as? [[String: AnyObject]] {
//                    print("jobs=\(jobs)")
//                }
//            }
//            
//            self.finished = true
//        }
//        
//        let failure = { (error: NSError?) -> Void in
//            print("error: \(error!)")
//            self.finished = true
//        }
//        
//        NetworkManager.sharedInstance().exec(httpMethod, urlString: urlString, headers: nil, parameters: parameters, values: nil, body: nil, dataOffset: 0, isJSON: true, success: success, failure: failure)
//    }
}
