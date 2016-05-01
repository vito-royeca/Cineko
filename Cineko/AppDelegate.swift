//
//  AppDelegate.swift
//  Cineko
//
//  Created by Jovit Royeca on 01/04/2016.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import UIKit

import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Crashlytics
        Fabric.with([Crashlytics.self])
        
        // Core Data
        CoreDataManager.sharedInstance().setup(Constants.CoreDataSQLiteFile, modelFile: Constants.CoreDataModelFile)
        
        // TMDB
        TMDBManager.sharedInstance().setup(Constants.TMDBAPIKeyValue)
        TMDBManager.sharedInstance().deleteRefreshData()
        
        // RT
        RTManager.sharedInstance().setup(Constants.RTAPIKeyValue)
        
        // Docs Directory
        print("docs = \(NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!)")
        
        // if we have TMDB session id show the main interface, else show the start page
        let viewControllerID = TMDBManager.sharedInstance().hasSessionID() ? "MainTabBarController" : "StartViewController"

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = storyboard.instantiateViewControllerWithIdentifier(viewControllerID)
        window!.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        CoreDataManager.sharedInstance().saveMainContext()
    }
}

