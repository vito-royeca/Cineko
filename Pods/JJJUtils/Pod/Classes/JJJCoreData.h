//
//  JJJCoreData.h
//  JJJ
//
//  Created by Jovito Royeca on 11/6/12.
//  Copyright (c) 2012 JJJ Software. All rights reserved.
//

#import <CoreData/CoreData.h>

#include "JJJConstants.h"

@interface JJJCoreData : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedInstanceWithModel:(NSString*) model;

- (BOOL)save;
- (id)createManagedObject:(NSString*)name;
- (BOOL)bIsTableEmpty:(NSString*)tableName;
- (int)tableCount:(NSString*)tableName;

- (NSArray*)find:(NSString*)tableName
      columnName:(NSString*)columnName
     columnValue:(id)columnValue
relationshipKeys:(NSArray*)relationshipKeys
         sorters:(NSArray*)sorters;

- (NSArray*)findAll:(NSString*)tableName
            sorters:(NSArray*)sorters;

@end
