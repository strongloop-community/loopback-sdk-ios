/**
 * @file LBInstallation.h
 * @author Raymond Feng
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */
#ifndef LoopBack_LBInstallation_h
#define LoopBack_LBInstallation_h

#import <LoopBack/LoopBack.h>

@class LBInstallation;
@class LBInstallationRepository;

/**
 * LBInstallation represents the installation of a given app on the device. It 
 * connects the device token with application/user/timeZone/subscriptions for
 * the server to find devices of interest for push notifications.
 */
@interface LBInstallation : LBModel

/**
 * The app id received from LoopBack application signup.
 * It's usaully configurd in the Settings.plist file
 */
@property (nonatomic, copy) NSString *appId;

/**
 * The application version, default to @"1.0.0"
 */
@property (nonatomic, copy) NSString *appVersion;

/**
 * The id for the signed in user for the installation
 */
@property (nonatomic, copy) NSString *userId;

/**
 * It's always @"ios"
 */
@property (nonatomic, readonly, copy) NSString *deviceType;

/**
 * The device token in hex string format
 */
@property (nonatomic, copy) NSString *deviceToken;

/**
 * The current badge
 */
@property (nonatomic, copy) NSNumber *badge;

/**
 * An array of topic names that the device subscribes to
 */
@property (nonatomic, copy) NSArray *subscriptions;

/**
 * The time zone for the server side to decide a good time for push
 */
@property (nonatomic, readonly, copy) NSString *timeZone;

/**
 * Status of the installation
 */
@property (nonatomic, copy) NSString *status;

/**
 * Convert the device token from NSData to NSString
 *
 * @param token The device token in NSData type
 * @return The device token in NSString type
 */
+ (NSString *)deviceTokenWithData: (NSData *) token;

/**
 * Register the device against LoopBack server
 * @param adapter The REST adapter
 * @param deviceToken The device token
 * @param registrationId The registration id
 * @param appId The application id
 * @param appVersion The application version
 * @param userId The user id
 * @param badge The badge
 * @param subscriptions An array of string values representing subscriptions to push events
 * @param success The success callback block for device registration
 * @param failure The failure callback block for device registration
 */
+ (void)registerDeviceWithAdapter: (LBRESTAdapter *) adapter
                      deviceToken: (NSData *) deviceToken
                   registrationId: (id) registrationId
                            appId: (NSString *) appId
                       appVersion: (NSString *) appVersion
                           userId: (NSString *) userId
                            badge: (NSNumber *) badge
                    subscriptions: (NSArray *) subscriptions
                          success: (SLSuccessBlock) success
                          failure: (SLFailureBlock) failure;

@end

/**
 * Custom ModelRepository subclass for LBInstallation
 */
@interface LBInstallationRepository : LBModelRepository

/**
 * Get a singleton for LBInstallationRepository
 */
+ (instancetype)repository;

@end

#endif
