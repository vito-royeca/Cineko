//
//  JJJCoreData.m
//  JJJ
//
//  Created by Jovito Royeca on 11/6/12.
//  Copyright (c) 2012 JJJ Software. All rights reserved.
//

#import "JJJCoreData.h"

@interface JJJCoreData()

@property(strong, nonatomic) NSString *model;

@end

@implementation JJJCoreData

static NSMutableDictionary *_singletons;

@synthesize model;
@synthesize managedObjectContext;
@synthesize managedObjectModel;
@synthesize persistentStoreCoordinator;

+(id) sharedInstanceWithModel:(NSString*) model
{
    if (!_singletons)
    {
        _singletons = [[NSMutableDictionary alloc] init];
    }
    
    JJJCoreData *me = [_singletons valueForKey:model];
    
    if (!me)
    {
        me = [[JJJCoreData alloc] init];
        [_singletons setValue:me forKey:model];
    }
    
    me.model = model;
    
    return me;
}

#pragma mark - DB Ops

- (BOOL)save
{
    NSError *error = nil;
    NSManagedObjectContext *moc = [self managedObjectContext];
    BOOL retVal = YES;
    
    if (moc)
    {
        if ([moc hasChanges])
        {
            if (![moc save:&error])
            {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@, %@", error, [error userInfo], [error localizedDescription]);
//                abort();
                retVal = NO;
            }
        }
    }
    
    return retVal;
}

- (id)createManagedObject:(NSString*)name
{
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:name
                                                            inManagedObjectContext:self.managedObjectContext];
    return object;
}

- (BOOL) bIsTableEmpty:(NSString*)tableName
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:1];
    
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects.count <= 0;
}

- (int)tableCount:(NSString*)tableName
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName
                                              inManagedObjectContext:[self managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    return (int)fetchedObjects.count;
}

- (NSArray*)find:(NSString*)tableName
      columnName:(NSString*)columnName
     columnValue:(id)columnValue
relationshipKeys:(NSArray*)relationshipKeys
         sorters:(NSArray*)sorters
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName
                                              inManagedObjectContext:[self managedObjectContext]];
    NSPredicate *predicate = [NSPredicate
                              predicateWithFormat:@"%K == %@", columnName, columnValue];
    
    if (relationshipKeys)
    {
        [fetchRequest setRelationshipKeyPathsForPrefetching:relationshipKeys];
    }
    if (sorters)
    {
        NSMutableArray *arrSorters = [[NSMutableArray alloc] initWithCapacity:sorters.count];
        
        for (NSDictionary *dict in sorters)
        {
            NSString *key = [[dict allKeys] objectAtIndex:0];
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]
                                            initWithKey:key ascending:[[dict objectForKey:key] boolValue]];
            [arrSorters addObject:descriptor];
        }
        [fetchRequest setSortDescriptors:arrSorters];
    }
    [fetchRequest setEntity:entity];
    [fetchRequest setPredicate:predicate];
    
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        NSLog(@"fetch error: %@ : %@", error, [error userInfo]);
        return [NSArray arrayWithObjects:nil, nil];
    }
    else
    {
        return fetchedObjects;
    }
}

- (NSArray*)findAll:(NSString*)tableName
            sorters:(NSArray*)sorters
{
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName
                                              inManagedObjectContext:[self managedObjectContext]];
    if (sorters)
    {
        NSMutableArray *arrSorters = [[NSMutableArray alloc] initWithCapacity:sorters.count];
        
        for (NSDictionary *dict in sorters)
        {
            NSString *key = [[dict allKeys] objectAtIndex:0];
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc]
                                            initWithKey:key ascending:[[dict objectForKey:key] boolValue]];
            [arrSorters addObject:descriptor];
        }
        [fetchRequest setSortDescriptors:arrSorters];
    }
    [fetchRequest setEntity:entity];
    
    NSArray *fetchedObjects = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (error)
    {
        NSLog(@"fetch error: %@ : %@", error, [error userInfo]);
        return [NSArray arrayWithObjects:nil, nil];
    }
    else
    {
        return fetchedObjects;
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext*)managedObjectContext
{
    if (managedObjectContext != nil)
    {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel*)managedObjectModel
{
    if (managedObjectModel != nil)
    {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:model withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator*)persistentStoreCoordinator
{
    if (persistentStoreCoordinator != nil)
    {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite", model]];
    
#if defined(_OS_IPHONE) || defined(_OS_IPHONE_SIMULATOR)
    if (![[NSFileManager defaultManager] fileExistsAtPath:[storeURL path]])
    {
        NSURL *preloadURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:model ofType:@"sqlite"]];
        NSError* error = nil;
        
        if (![[NSFileManager defaultManager] copyItemAtURL:preloadURL toURL:storeURL error:&error])
        {
            NSLog(@"Error copying database.sqlite: %@", error);
        }
    }
#endif
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],
                          NSMigratePersistentStoresAutomaticallyOption,
                          [NSNumber numberWithBool:YES],
                          NSInferMappingModelAutomaticallyOption, nil];
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:dict
                                                          error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
