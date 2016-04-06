#import "DATAObjectIDs.h"

@implementation DATAObjectIDs

+ (NSDictionary *)objectIDsInEntityNamed:(NSString *)entityName
                     withAttributesNamed:(NSString *)attributeName
                                 context:(NSManagedObjectContext *)context
{
    return [self objectIDsInEntityNamed:entityName
                    withAttributesNamed:attributeName
                                context:context
                              predicate:nil];
}

+ (NSDictionary *)objectIDsInEntityNamed:(NSString *)entityName
                     withAttributesNamed:(NSString *)attributeName
                                 context:(NSManagedObjectContext *)context
                               predicate:(NSPredicate *)predicate
{
    __block NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

    [context performBlockAndWait:^{
        NSExpressionDescription *expression = [[NSExpressionDescription alloc] init];
        expression.name = @"objectID";
        expression.expression = [NSExpression expressionForEvaluatedObject];
        expression.expressionResultType = NSObjectIDAttributeType;

        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        request.predicate = predicate;
        request.resultType = NSDictionaryResultType;
        request.propertiesToFetch = @[expression, attributeName];

        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"error fetching IDs: %@", [error description]);
        }

        for (NSDictionary *object in objects) {
            id fetchedID = [object valueForKeyPath:attributeName];
            NSManagedObjectID *objectID = [object valueForKeyPath:@"objectID"];
            if ([dictionary objectForKey:fetchedID] || !fetchedID) {
                [context deleteObject:[context objectWithID:objectID]];
            } else {
                [dictionary setObject:objectID forKey:fetchedID];
            }
        }
    }];

    return dictionary;
}

+ (NSArray *)objectIDsInEntityNamed:(NSString *)entityName
                            context:(NSManagedObjectContext *)context
{
    return [self objectIDsInEntityNamed:entityName
                                context:context
                              predicate:nil];
}

+ (NSArray *)objectIDsInEntityNamed:(NSString *)entityName
                            context:(NSManagedObjectContext *)context
                          predicate:(NSPredicate *)predicate
{
    __block NSArray *objectIDs;

    [context performBlockAndWait:^{
        NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entityName];
        request.predicate = predicate;
        request.resultType = NSManagedObjectIDResultType;

        NSError *error = nil;
        objectIDs = [context executeFetchRequest:request error:&error];
        if (error) {
            NSLog(@"error fetching IDs: %@", [error description]);
        }
    }];

    return objectIDs;
}

@end
