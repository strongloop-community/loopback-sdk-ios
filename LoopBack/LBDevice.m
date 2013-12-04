#import "LBDevice.h"

@implementation LBDevice

/*
- (NSString *)description {
    return [NSString stringWithFormat: @"<LBDevice id: %@ deviceToken: %@>", self.id, self.deviceToken];
}
*/ 

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
        device.id = device._id;
        NSLog(@"Successfully saved %@", device);
        success(device);
    } failure:^(NSError *error) {
        NSLog(@"Failed to save %@ with %@", device, error);
        failure(error);
    }];
}

/**
 * Saves the desired Device model to the server with all values pulled from the UI.
 */
+ (void)registerDevice:(LBRESTAdapter *) adapter
           deviceToken: (NSData *) deviceToken
        registrationId: (NSNumber *) registrationId
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
    LBDevice *model = (LBDevice *)[repository modelWithDictionary:@{}];
    
    
    model.appId = appId;
    model.appVersion = appVersion;
    model.userId = userId;
    model.deviceType = @"ios";
    model.deviceToken = hexToken;
    model.status = @"Active";
    model.badge = badge;
    
    if(registrationId) {
        model.id = registrationId;
    }
    
    [LBDevice registerDevice:model success:success failure:failure];
}

@end


@implementation LBDeviceRepository

+ (instancetype)repository {
    LBDeviceRepository *repository = [self repositoryWithClassName:@"devices"];
    repository.modelClass = [LBDevice class];
    return repository;
}

@end

