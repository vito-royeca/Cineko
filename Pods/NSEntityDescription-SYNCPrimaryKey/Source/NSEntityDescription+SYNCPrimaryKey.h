@import CoreData;

static NSString * _Nonnull const SYNCDefaultLocalPrimaryKey = @"remoteID";
static NSString * _Nonnull const SYNCDefaultRemotePrimaryKey = @"id";

static NSString * _Nonnull const SYNCCustomLocalPrimaryKey = @"hyper.isPrimaryKey";
static NSString * _Nonnull const SYNCCustomRemoteKey = @"hyper.remoteKey";

@interface NSEntityDescription (SYNCPrimaryKey)

- (nonnull NSAttributeDescription *)sync_primaryKeyAttribute;

- (nonnull NSString *)sync_localKey;

- (nonnull NSString *)sync_remoteKey;

@end
