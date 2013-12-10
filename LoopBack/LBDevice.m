#import "LBDevice.h"

@interface LBDevice ()
@property (nonatomic, readwrite, copy) NSString *deviceType;
@end

@implementation LBDevice

+ (NSString *)deviceTokenWithData: (NSData *) token {
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
+ (void)registerDeviceWithAdapter: (LBRESTAdapter *) adapter
                      deviceToken: (NSData *) deviceToken
                   registrationId: (id) registrationId
                            appId: (NSString *) appId
                       appVersion: (NSString *) appVersion
                           userId: (NSString *) userId
                            badge: (NSNumber *) badge
                          success: (SLSuccessBlock) success
                          failure: (SLFailureBlock) failure {
    
    NSString* hexToken = [LBDevice deviceTokenWithData:deviceToken];
    
    LBDeviceRepository *repository = (LBDeviceRepository *) [adapter repositoryWithClass:[LBDeviceRepository class]];
    
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


@end

@implementation LBDeviceRepository

+ (instancetype)repository {
    static LBDeviceRepository *singleton = nil;
    @synchronized(self) {
        if(singleton == nil) {
            singleton = [self repositoryWithClassName:@"devices"];
            singleton.modelClass = [LBDevice class];
        }
    }
    return singleton;
}

@end

