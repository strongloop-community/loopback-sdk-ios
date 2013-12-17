//
//  LBInstallation.h
//
//  Created by Raymond Feng on 11/20/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#ifndef LoopBack_LBInstallation_h
#define LoopBack_LBInstallation_h

#import <LoopBack/LoopBack.h>

@class LBInstallation;
@class LBInstallationRepository;

@interface LBInstallation : LBModel

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, readonly, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSNumber *badge;
@property (nonatomic, copy) NSArray *subscriptions;
@property (nonatomic, readonly, copy) NSString *timeZone;
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
 * @param deviceToken The device token
 * @param registrationId The registration id
 * @param appId The application id
 * @param appVersion The application version
 * @param userIs The user id
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
