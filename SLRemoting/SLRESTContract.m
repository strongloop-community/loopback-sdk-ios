/**
 * @file SLRESTContract.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLRESTContract.h"

NSString *SLRESTContractDefaultVerb = @"POST";

@interface SLRESTContractItem()

@property (readwrite, nonatomic, copy) NSString *pattern;
@property (readwrite, nonatomic, copy) NSString *verb;
@property (readwrite, nonatomic, assign) BOOL multipart;
@property (readwrite, nonatomic, assign) BOOL binaryCallback;

/**
 * Initializes a new item to encapsulate the given pattern.
 *
 * @param  pattern  The pattern to represent.
 * @return          The item.
 */
- (instancetype)initWithPattern:(NSString *)pattern;

/**
 * Initializes a new item encapsulating the given pattern and verb.
 *
 * @param  pattern  The pattern to represent.
 * @param  verb     The verb to represent.
 * @return          A new item.
 */
- (instancetype)initWithPattern:(NSString *)pattern verb:(NSString *)verb;

/**
 * Initializes a new item encapsulating the given pattern, verb and multipart setting.
 *
 * @param  pattern   The pattern to represent.
 * @param  verb      The verb to represent.
 * @param multiplart Indicates this item is a multipart mime type.
 * @return           A new item.
 */
- (instancetype)initWithPattern:(NSString *)pattern verb:(NSString *)verb multipart:(BOOL)multipart;

@end

@interface SLRESTContract()

@property (readwrite, nonatomic) NSDictionary *dict;

@end

@implementation SLRESTContractItem

+ (instancetype)itemWithPattern:(NSString *)pattern {
    return [[self alloc] initWithPattern:pattern];
}

- (instancetype)initWithPattern:(NSString *)pattern {
    return [self initWithPattern:pattern verb:@"POST"];
}

+ (instancetype)itemWithPattern:(NSString *)pattern
                           verb:(NSString *)verb {
    return [[self alloc] initWithPattern:pattern verb:verb];
}

- (instancetype)initWithPattern:(NSString *)pattern
                           verb:(NSString *)verb {
    self = [super init];

    if (self) {
        self.pattern = pattern;
        self.verb = verb;
    }

    return self;
}

+ (instancetype)itemWithPattern:(NSString *)pattern
                           verb:(NSString *)verb
                      multipart:(BOOL)multipart {
    return [[self alloc] initWithPattern:pattern verb:verb multipart:multipart];
}

- (instancetype)initWithPattern:(NSString *)pattern
                           verb:(NSString *)verb
                      multipart:(BOOL)multipart {
    self = [super init];
    
    if (self) {
        self.pattern = pattern;
        self.verb = verb;
        self.multipart = multipart;
    }
    
    return self;
}

@end

@implementation SLRESTContract

+ (instancetype)contract {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];

    if (self) {
        self.dict = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)addItem:(SLRESTContractItem *)item
      forMethod:(NSString *)method {
    NSParameterAssert(item);
    NSParameterAssert(method);

    ((NSMutableDictionary *)self.dict)[method] = item;
}

- (void)addItemsFromContract:(SLRESTContract *)contract {
    NSParameterAssert(contract);

    [(NSMutableDictionary *)self.dict addEntriesFromDictionary:contract.dict];
}

- (NSString *)urlForMethod:(NSString *)method
                parameters:(NSMutableDictionary *)parameters {
    NSParameterAssert(method);

    NSString *pattern = [self patternForMethod:method];

    if (pattern) {
        return [self urlWithPattern:pattern parameters:parameters];
    } else {
        return [self urlForMethodWithoutItem:method];
    }
}

- (NSString *)verbForMethod:(NSString *)method {
    NSParameterAssert(method);

    SLRESTContractItem *item = (SLRESTContractItem *)self.dict[method];

    return item ? item.verb : @"POST";
}

- (BOOL)multipartForMethod:(NSString *)method
{
    NSParameterAssert(method);
    
    SLRESTContractItem *item = (SLRESTContractItem *)self.dict[method];
    
    return item.multipart;
}

- (NSString *)urlForMethodWithoutItem:(NSString *)method {
    return [method stringByReplacingOccurrencesOfString:@"." withString:@"/"];
}

- (NSString *)patternForMethod:(NSString *)method {
    NSParameterAssert(method);

    SLRESTContractItem *item = (SLRESTContractItem *)self.dict[method];

    return item ? item.pattern : nil;
}

- (NSString *)urlWithPattern:(NSString *)pattern
                  parameters:(NSMutableDictionary *)parameters {
    NSParameterAssert(pattern);

    if (!parameters) {
        return pattern;
    }

    NSString *url = pattern;

    for (NSString *key in parameters.allKeys) { // create a copy of allKeys to mutate parameters
        NSString *keyPattern = [NSString stringWithFormat:@":%@", key];
        if ([url rangeOfString:keyPattern].location == NSNotFound) continue;
        
        NSString *valueStr = [NSString stringWithFormat:@"%@", parameters[key]];
        url = [url stringByReplacingOccurrencesOfString:keyPattern withString:valueStr];
        [parameters removeObjectForKey:key];
    }

    return url;
}

@end
