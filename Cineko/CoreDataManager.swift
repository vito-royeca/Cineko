//
//  DataManager.swift
//  Cineko
//
//  Created by Jovit Royeca on 3/18/16.
//  Copyright © 2016 Jovito Royeca. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataError: ErrorType {
    case NoSQLiteFile
    case NoModelFile
}

class CoreDataManager: NSObject {
    // MARK: Variables
    private var sqliteFile:String?
    private var modelFile:String?
    
    // MARK: Setup
    func setup(sqliteFile: String, modelFile: String) {
        self.sqliteFile = sqliteFile
        self.modelFile = modelFile
        
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).first
        let storePath = "\(documentPath!)/\(sqliteFile)"
        
        if !NSFileManager.defaultManager().fileExistsAtPath(storePath) {
            let preloadPath = "\(NSBundle.mainBundle().bundlePath)/\(sqliteFile)"
            
            if NSFileManager.defaultManager().fileExistsAtPath(preloadPath) {
                do {
                    try NSFileManager.defaultManager().copyItemAtPath(preloadPath, toPath: storePath)
                } catch {
                    print("Error copying \(sqliteFile)")
                }
            }
        }
    }
    
    // MARK: - The Core Data stack. The code has been moved, unaltered, from the AppDelegate.
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let arr = self.modelFile!.componentsSeparatedByString(".")
        let modelURL = NSBundle.mainBundle().URLForResource(arr.first, withExtension: arr.last)!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent(self.sqliteFile!)
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let options = [NSMigratePersistentStoresAutomaticallyOption : true,
                           NSInferMappingModelAutomaticallyOption : true]
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var mainObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var mainObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        mainObjectContext.persistentStoreCoordinator = coordinator
        return mainObjectContext
    }()
    
    lazy var privateContext: NSManagedObjectContext = {
        var privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.parentContext = self.mainObjectContext
        return privateContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveMainContext () {
        if mainObjectContext.hasChanges {
            do {
                try mainObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func savePrivateContext() {
        if privateContext.hasChanges {
            do {
                try privateContext.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
            
            mainObjectContext.performBlockAndWait {
                do {
                    try self.mainObjectContext.save()
                } catch {
                    let nserror = error as NSError
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                    abort()
                }
            }
        }
    }
    
    // MARK: - Shared Instance
    static let sharedInstance = CoreDataManager()
}
