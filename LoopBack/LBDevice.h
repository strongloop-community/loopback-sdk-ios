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

typedef void (^DeviceRegistrationCallback)(NSError *err, LBDevice *model);

@interface LBDevice : LBModel

@property (nonatomic, copy) NSNumber *id;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *appVersion;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString* deviceType;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, copy) NSNumber *badge;
@property (nonatomic, copy) NSString *status;

/**
 * Convert the device token from NSData to NSString
 *
 * @param token The device token in NSData type
 * @return The device token in NSString type
 */
+ (NSString *)deviceToken: (NSData *) token;

/**
 * Register the device token
 * @param deviceToken The device token
 * @param registrationId The registration id
 * @param appId The application id
 * @param appVersion The application version
 * @param userIs The user id
 * @param badge The badge
 * @param callback The callback block for device registration
 */
+ (void)registerDevice: (LBRESTAdapter *) adapter
           deviceToken: (NSData *)deviceToken
        registrationId:(NSNumber *)registrationId
                 appId:(NSString *) appId
            appVersion:(NSString * ) appVersion
                userId:(NSString *) userId
                 badge: (NSNumber *) badge
              callback:(DeviceRegistrationCallback) callback;

/**
 * Register the device token
 * @param device The device information
 * @param callback The callback block for device registration
 */
+ (void)registerDevice: (LBDevice *) device callback: (DeviceRegistrationCallback) callback;


@end


/**
 * Our custom ModelRepository subclass. See Lesson One for more information.
 */
@interface LBDeviceRepository : LBModelRepository

+ (instancetype)repository;

@end


#endif
