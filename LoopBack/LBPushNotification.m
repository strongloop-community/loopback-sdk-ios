/**
 * @file LBPushNotification.m
 *
 * @author Raymond Feng
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "LBPushNotification.h"
#import "LBInstallation.h"

@implementation LBPushNotification

- (id)initWithTypeAndUserInfo:(LBPushNotificationType) type userInfo:(NSDictionary *) userInfo {
    self = [super init];
    self.type = type;
    self.userInfo = userInfo;
    return self;
}

+ (LBPushNotification *) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Let the device know we want to receive push notifications
#ifdef __IPHONE_8_0
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        // iOS 8 or later
        UIUserNotificationType types = UIUserNotificationTypeBadge |
                                       UIUserNotificationTypeSound |
                                       UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else
#endif
    {
        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert;
        [application registerForRemoteNotificationTypes:types];
    }

    // Handle APN on Terminated state, app launched because of APN
    NSDictionary *payload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];

    if (payload) {
        // There is an offline notification
        return [[LBPushNotification alloc] initWithTypeAndUserInfo:Terminated userInfo:payload];
    } else {
        return nil;
    }
}

+ (LBPushNotification *) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Detect if APN is received on Background or Foreground state
    if (application.applicationState == UIApplicationStateInactive) {
        return [[LBPushNotification alloc] initWithTypeAndUserInfo:Background userInfo:userInfo];
    }
    else if (application.applicationState == UIApplicationStateActive) {
        return [[LBPushNotification alloc] initWithTypeAndUserInfo:Foreground userInfo:userInfo];
    }
    return nil;
}

+ (NSInteger) resetBadge:(NSInteger)badge {
    UIApplication *app = [UIApplication sharedApplication];
    NSInteger current = app.applicationIconBadgeNumber;
    if(badge < 0) {
        app.applicationIconBadgeNumber = 0;
    } else {
        app.applicationIconBadgeNumber = badge;
    }
    return current;
}

+ (NSInteger) getBadge {
    UIApplication *app = [UIApplication sharedApplication];
    return app.applicationIconBadgeNumber;
}

+ (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
            adapter:(LBRESTAdapter *)adapter userId:(NSString *) userId subscriptions:(NSArray *)subscriptions
            success:(SLSuccessBlock)success failure:(SLFailureBlock)failure
{
	NSLog(@"My token is: %@", deviceToken);
    
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.plist"];
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:path];
    
    NSNumber *badge = [NSNumber numberWithLong: application.applicationIconBadgeNumber];
    
    [LBInstallation registerDeviceWithAdapter: adapter
                                  deviceToken: deviceToken
                               registrationId: nil
                                        appId: settings[@"AppId"]
                                   appVersion: settings[@"AppVersion"]
                                       userId: userId
                                        badge: badge
                                subscriptions: subscriptions
                                      success: success
                                      failure: failure];
    
}

+ (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"Failed to get token, error: %@", error);
}

@end
