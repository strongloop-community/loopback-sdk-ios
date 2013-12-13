//
//  LBPushNotification.h
//
//  Created by Raymond Feng on 11/20/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#ifndef LoopBack_LBPushNotification_h
#define LoopBack_LBPushNotification_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <LoopBack/LoopBack.h>

/**
 @typedef LBPushNotificationType enum
 
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

@interface LBPushNotification : NSObject

@property (nonatomic) LBPushNotificationType type;
@property (nonatomic) NSDictionary *userInfo;

/**
 * This method should be called within UIApplicationDelegate's application method.
 * - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 * @param launchOptions The launch options from the application hook
 * @return The offline notification
 */
+ (LBPushNotification *) launch:(NSDictionary *)launchOptions;

/**
 * Handle received notification
 * @param application The application instance
 * @param userInfo The payload
 * @return The received notification
 */
+ (LBPushNotification *) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 * Handle the device token
 * @param deviceToken The device token
 * @param adapter The REST adapter
 * @param success The success callback block
 * @param failure The failure callback block
 */
+ (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
            adapter:(LBRESTAdapter *) adapter success:(SLSuccessBlock)success failure:(SLFailureBlock)failure;

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
