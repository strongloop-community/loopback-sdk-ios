//
//  LBDevice.h
//
//  Created by Raymond Feng on 11/20/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#ifndef LoopBack_LBDevice_h
#define LoopBack_LBDevice_h

#import <LoopBack/LoopBack.h>

@class LBDevice;
@class LBDeviceRepository;

@interface LBDevice : LBModel

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSNumber *badge;
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
                          success: (SLSuccessBlock) success
                          failure: (SLFailureBlock) failure;

@end

/**
 * Custom ModelRepository subclass for LBDevice
 */
@interface LBDeviceRepository : LBModelRepository

/**
 * Get a singleton for LBDeviceRepository
 */
+ (instancetype)repository;

@end

#endif
