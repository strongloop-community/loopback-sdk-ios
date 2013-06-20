//
//  SLRESTContract.h
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/6/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *SLRESTContractDefaultVerb;

@interface SLRESTContractItem : NSObject 

@property (readonly, nonatomic, copy) NSString *pattern;
@property (readonly, nonatomic, copy) NSString *verb;

+ (instancetype)itemWithPattern:(NSString *)pattern;
- (instancetype)initWithPattern:(NSString *)pattern;
+ (instancetype)itemWithPattern:(NSString *)pattern verb:(NSString *)verb;
- (instancetype)initWithPattern:(NSString *)pattern verb:(NSString *)verb;

@end

@interface SLRESTContract : NSObject

@property (readonly, nonatomic) NSDictionary *dict;

+ (instancetype)contract;

- (void)addItem:(SLRESTContractItem *)item forMethod:(NSString *)method;
- (void)addItemsFromContract:(SLRESTContract *)contract;

- (NSString *)urlForMethod:(NSString *)method
                parameters:(NSDictionary *)parameters;
- (NSString *)verbForMethod:(NSString *)method;

- (NSString *)urlForMethodWithoutItem:(NSString *)method;
- (NSString *)patternForMethod:(NSString *)method;
- (NSString *)urlWithPattern:(NSString *)pattern
                  parameters:(NSDictionary *)parameters;

@end
