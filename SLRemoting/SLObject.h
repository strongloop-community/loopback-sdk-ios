//
//  SLRObject.h
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/5/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SLAdapter.h"

extern NSString *SLObjectInvalidPrototypeDescription;

@class SLPrototype;

@interface SLObject : NSObject

@property (readonly, nonatomic, weak) SLPrototype *prototype;
@property (readonly, nonatomic, strong) NSDictionary *creationParameters;

+ (instancetype)objectWithPrototype:(SLPrototype *)prototype
                         parameters:(NSDictionary *)parameters;
- (instancetype)initWithPrototype:(SLPrototype *)prototype
                       parameters:(NSDictionary *)parameters;

- (void)invokeMethod:(NSString *)name
          parameters:(NSDictionary *)parameters
             success:(SLSuccessBlock)success
             failure:(SLFailureBlock)failure;

@end

@interface SLPrototype : NSObject

@property (readonly, nonatomic, copy) NSString *className;
@property (readwrite, nonatomic) SLAdapter *adapter;

+ (instancetype)prototypeWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name;

- (SLObject *)objectWithParameters:(NSDictionary *)parameters;

- (void)invokeStaticMethod:(NSString *)name
                parameters:(NSDictionary *)parameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure;

@end
