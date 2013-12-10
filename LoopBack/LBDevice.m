#import "LBDevice.h"

@implementation LBDevice

+ (NSString *)deviceToken: (NSData *) token {
    // Convert device token from NSData to NSString
    const unsigned *tokenBytes = [token bytes];
    NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                          ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                          ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                          ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    return hexToken;
}

+ (void)registerDevice: (LBDevice *) device
               success: (SLSuccessBlock) success
               failure: (SLFailureBlock) failure {
    // Save!
    [device saveWithSuccess:^{
        NSLog(@"LBDevice: Successfully saved %@", device);
        success(device);
    } failure:^(NSError *error) {
        NSLog(@"LBDevice: Failed to save %@ with %@", device, error);
        failure(error);
    }];
}

/**
 * Saves the desired Device model to the server with all values pulled from the UI.
 */
+ (void)registerDevice:(LBRESTAdapter *) adapter
           deviceToken: (NSData *) deviceToken
        registrationId: (id) registrationId
                 appId: (NSString *) appId
            appVersion: (NSString *) appVersion
                userId: (NSString *) userId
                 badge: (NSNumber *) badge
               success: (SLSuccessBlock) success
               failure: (SLFailureBlock) failure {
    
    NSString* hexToken = [LBDevice deviceToken:deviceToken];
    
    LBDeviceRepository *repository = (LBDeviceRepository *) [adapter repositoryWithModelClass:[LBDeviceRepository class]];
    
    if(appVersion == nil) {
        appVersion = @"1.0.0";
    }
    
    // 3. From that repository, create a new LBDevice.
    LBDevice *model = nil;
    
    if(registrationId) {
        model = (LBDevice *)[repository modelWithDictionary:@{@"id": registrationId}];
    } else {
        // The repository doesn't seem to accept nil as the value for id
        model = (LBDevice *)[repository modelWithDictionary:@{}];
    }
    
    model.appId = appId;
    model.appVersion = appVersion;
    model.userId = userId;
    model.deviceType = @"ios";
    model.deviceToken = hexToken;
    model.status = @"Active";
    model.badge = badge;
    
    [LBDevice registerDevice:model success:success failure:failure];
}

- (void) storeLocally {
    
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our Data/plist file
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"LBDevice.plist"];
        
    // create dictionary with values in UITextFields
    NSDictionary *plistDict = [self toDictionary];
    NSString *error = nil;
    // create NSData from dictionary
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict
                                                                   format:NSPropertyListXMLFormat_v1_0
                                                         errorDescription:&error];
        
    // check is plistData exists
    if(plistData) {
        // write plistData to our Data.plist file
        [plistData writeToFile:plistPath atomically:YES];
    } else {
        NSLog(@"Error in saveData: %@", error);
    }
}

+ (LBDevice *) loadLocally:(LBDeviceRepository *) repository {
    // Data.plist code
    // get paths from root direcory
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    // get documents path
    NSString *documentsPath = [paths objectAtIndex:0];
    // get the path to our LBDevice/plist file
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"LBDevice.plist"];
    
    // check to see if LBDevice.plist exists in documents
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        // if not in documents, get property list from main bundle
        plistPath = [[NSBundle mainBundle] pathForResource:@"LBDevice" ofType:@"plist"];
    }
    
    // read property list into memory as an NSData object
    NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
    NSString *errorDesc = nil;
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
    // convert static property liost into dictionary object
    NSDictionary *temp = (NSDictionary *)
        [NSPropertyListSerialization propertyListFromData:plistXML
                                         mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                   format:&format errorDescription:&errorDesc];
    if (!temp) {
        NSLog(@"Error reading plist: %@", errorDesc);
        return nil;
    } else {
        return (LBDevice *)[repository modelWithDictionary:temp];
    }
}

@end

@implementation LBDeviceRepository

+ (instancetype)repository {
    LBDeviceRepository *repository = [self repositoryWithClassName:@"devices"];
    repository.modelClass = [LBDevice class];
    return repository;
}

@end

