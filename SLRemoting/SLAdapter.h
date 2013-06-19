//
//  SLRAdapter.h
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/5/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SLSuccessBlock)(id value);
typedef void (^SLFailureBlock)(NSError *error);

extern NSString *SLAdapterNotConnectedErrorDescription;

@interface SLAdapter : NSObject

@property (readonly, nonatomic) BOOL connected;

+ (instancetype)adapter;
+ (instancetype)adapterWithURL:(NSURL *)url;

- (instancetype)initWithURL:(NSURL *)url;

- (void)connectToURL:(NSURL *)url;

- (void)invokeStaticMethod:(NSString *)method
                parameters:(NSDictionary *)parameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure;

- (void)invokeInstanceMethod:(NSString *)method
       constructorParameters:(NSDictionary *)constructorParameters
                  parameters:(NSDictionary *)parameters
                     success:(SLSuccessBlock)success
                     failure:(SLFailureBlock)failure;

@end
