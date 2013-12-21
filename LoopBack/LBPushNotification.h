/**
 * @file LBPushNotification.h
 * @author Raymond Feng
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#ifndef LoopBack_LBPushNotification_h
#define LoopBack_LBPushNotification_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <LoopBack/LoopBack.h>

/**
 @abstract Push Notification Type: Indicates in what state was app when received it (Foreground, Background, Terminated)
 
 @discussion
 */
typedef enum LBPushNotificationType {
  /** App was on Foreground */
  Foreground   = 1,
  /** App was on Background */
  Background   = 2,
  /** App was terminated and launched again through Push notification */
  Terminated   = 3
} LBPushNotificationType;

/**
 * Wrapper class to handle received push notifications
 * @experimental(Provide helper methods for iOS clients to handle push notifications)
 */
@interface LBPushNotification : NSObject

/**
 * The notification type
 */
@property (nonatomic) LBPushNotificationType type;

/**
 * The notification payload
 */
@property (nonatomic) NSDictionary *userInfo;

/**
 * This method should be called within UIApplicationDelegate's application method.
 * - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 * @param application The application
 * @param launchOptions The launch options from the application hook
 * @return The offline notification
 */
+ (LBPushNotification *) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

/**
 * Handle received notification
 * @param application The application instance
 * @param userInfo The payload
 * @return The received notification
 */
+ (LBPushNotification *) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 * Handle the device token
 * @param application The application instance
 * @param deviceToken The device token
 * @param adapter The REST adapter
 * @param userId The user id
 * @param subscriptions The list of subscribed topics
 * @param success The success callback block
 * @param failure The failure callback block
 */
+ (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
            adapter:(LBRESTAdapter *)adapter userId:(NSString *)userId subscriptions:(NSArray *)subscriptions
            success:(SLSuccessBlock)success failure:(SLFailureBlock)failure;

/**
 * Handle failure to receive device token
 */
+ (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;

/**
 * Reset badge
 * @param badge The new badge value
 * @return The old badge
 */
+ (NSInteger) resetBadge:(NSInteger)badge;

/**
 * Get the current badge value
 * @return The badge value
 */
+ (NSInteger) getBadge;

@end

#endif
