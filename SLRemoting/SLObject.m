/**
 * @file SLObject.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLObject.h"

@interface SLObject()

@property (readwrite, nonatomic, strong) SLRepository *repository;
@property (readwrite, nonatomic, strong) NSDictionary *creationParameters;

@end

@interface SLRepository()

@property (readwrite, nonatomic, copy) NSString *className;

@end


@implementation NSDate (SLObjectAdditions)

static NSDateFormatter *jsonDateFormatterISO8601 = nil; // for property encoding
static NSDateFormatter *jsonDateFormatterDefault = nil; // for argument encoding

+ (void)initJSONFormatterIfNecessary {
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        // Ref: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns

        jsonDateFormatterISO8601 = [[NSDateFormatter alloc] init];
        // 2012-12-22T21:39:22.123Z
        [jsonDateFormatterISO8601 setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [jsonDateFormatterISO8601 setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];

        jsonDateFormatterDefault = [[NSDateFormatter alloc] init];
        // Wed Dec 17 2003 03:24:00 GMT+0900
        [jsonDateFormatterDefault setDateFormat:@"eee MMM dd yyyy HH:mm:ss 'GMT'ZZZ"];
        [jsonDateFormatterDefault setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });
}

+ (NSDate *)dateFromJSONString:(NSString *)jsonString {
    [self initJSONFormatterIfNecessary];

    NSDate *date = [jsonDateFormatterISO8601 dateFromString:jsonString];
    if (date == nil) {
        // Get rid of the "(JST)" part of "Thu Jan 01 1970 09:00:00 GMT+0900 (JST)" if exists.
        NSString *jsonNoTimeZone = [[jsonString componentsSeparatedByString:@"("] objectAtIndex:0];
        date = [jsonDateFormatterDefault dateFromString:jsonNoTimeZone];
    }
    return date;
}

- (NSString *)convertToJSONString {
    [self.class initJSONFormatterIfNecessary];

    return [jsonDateFormatterISO8601 stringFromDate:self];
}

@end

@implementation NSArray (SLObjectAdditions)

- (NSMutableData*) convertToMutableData {
    NSUInteger n = [self count];
    NSMutableData *data = [NSMutableData dataWithLength: n];
    char *p = [data mutableBytes];
    for (int i = 0; i < [self count]; i++) {
        *p++ = [[self objectAtIndex:i] charValue];
    }
    return data;
}

@end

@implementation NSMutableData (SLObjectAdditions)

+ (NSMutableData *)dataFromJSONObject:(NSDictionary *)jsonObject {
    // jsonObject is assumed to be a Node.js Buffer object
    if ([jsonObject count] != 2 ||
        ![(NSString *)(jsonObject[@"type"]) isEqualToString:@"Buffer"] ||
        ![jsonObject[@"data"] isKindOfClass:[NSArray class]]) {

        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:
                                               @"Argument doesn't follow the Buffer serialization format: %@",
                                               jsonObject]
                                     userInfo:nil];
    }
    NSArray *array = jsonObject[@"data"];
    NSMutableData *data = [array convertToMutableData];

    return data;
}

@end

@implementation NSData (SLObjectAdditions)

- (NSDictionary *)convertToJSONObject {
    NSMutableDictionary *jsonObject = [NSMutableDictionary dictionary];
    [jsonObject setObject:@"Buffer" forKey:@"type"];

    NSMutableArray *array = [NSMutableArray array];
    [self enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        for (NSInteger i = 0; i < byteRange.length; i++) {
            [array addObject:[NSNumber numberWithChar:((char*)bytes)[i]]];
        }
    }];
    [jsonObject setObject:array forKey:@"data"];

    return jsonObject;
}

@end

@implementation CLLocation (SLObjectAdditions)

+ (CLLocation *)locationFromJSONObject:(NSDictionary *)jsonObject {
    if ([jsonObject count] != 2 || jsonObject[@"lat"] == nil || jsonObject[@"lng"] == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:
                                               @"Argument doesn't follow the GeoPoint serialization format: %@",
                                               jsonObject]
                                     userInfo:nil];
    }
    CLLocationDegrees lat = ((NSNumber *)jsonObject[@"lat"]).doubleValue;
    CLLocationDegrees lng = ((NSNumber *)jsonObject[@"lng"]).doubleValue;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];

    return location;
}

- (NSDictionary *)convertToJSONObject {
    return @{ @"lat": @( self.coordinate.latitude ), @"lng": @( self.coordinate.longitude ) };
}

@end


@implementation SLObject

NSString *SLObjectInvalidRepositoryDescription = @"Invalid repository.";

+ (instancetype)objectWithRepository:(SLRepository *)repository
                         parameters:(NSDictionary *)parameters {
    return [[self alloc] initWithRepository:repository parameters:parameters];
}

- (instancetype)initWithRepository:(SLRepository *)repository
                       parameters:(NSDictionary *)parameters {
    self = [super init];

    if (self) {
        self.repository = repository;
        self.creationParameters = [SLObject convertArguments:parameters];
    }

    return self;
}

- (void)invokeMethod:(NSString *)name
          parameters:(NSDictionary *)parameters
             success:(SLSuccessBlock)success
             failure:(SLFailureBlock)failure {
    NSAssert(self.repository, SLObjectInvalidRepositoryDescription);

    NSString *path = [NSString stringWithFormat:@"%@.prototype.%@",
                      self.repository.className,
                      name];

    [self.repository.adapter invokeInstanceMethod:path
                            constructorParameters:self.creationParameters
                                       parameters:[SLObject convertArguments:parameters]
                                   bodyParameters:nil
                                     outputStream:nil
                                          success:success
                                          failure:failure];
}

- (void)invokeMethod:(NSString *)name
          parameters:(NSDictionary *)parameters
      bodyParameters:(NSDictionary *)bodyParameters
             success:(SLSuccessBlock)success
             failure:(SLFailureBlock)failure {
    NSAssert(self.repository, SLObjectInvalidRepositoryDescription);

    NSString *path = [NSString stringWithFormat:@"%@.prototype.%@",
                      self.repository.className,
                      name];

    [self.repository.adapter invokeInstanceMethod:path
                            constructorParameters:self.creationParameters
                                       parameters:[SLObject convertArguments:parameters]
                                   bodyParameters:[SLObject convertProperties:bodyParameters]
                                     outputStream:nil
                                          success:success
                                          failure:failure];
}

- (void)invokeMethod:(NSString *)name
          parameters:(NSDictionary *)parameters
        outputStream:(NSOutputStream *)outputStream
             success:(SLSuccessBlock)success
             failure:(SLFailureBlock)failure {

    NSAssert(self.repository, SLObjectInvalidRepositoryDescription);

    NSString *path = [NSString stringWithFormat:@"%@.prototype.%@",
                      self.repository.className,
                      name];

    [self.repository.adapter invokeInstanceMethod:path
                            constructorParameters:self.creationParameters
                                       parameters:[SLObject convertArguments:parameters]
                                   bodyParameters:nil
                                     outputStream:outputStream
                                          success:success
                                          failure:failure];
}

+ (NSDictionary *)convertArguments:(NSDictionary *)prop {
    NSMutableDictionary *converted = [NSMutableDictionary dictionary];
    for(id key in prop) {
        id value = [prop objectForKey:key];
        if ([value isKindOfClass:[NSDate class]]) {
            NSString *jsonString = [value convertToJSONString];
            value = @{ @"$type": @"date", @"$data": jsonString };
        } else if ([value isKindOfClass:[NSData class]]) {
            NSString *base64string = [value base64EncodedStringWithOptions:0];
            value = @{ @"$type": @"base64", @"$data": base64string };
        } else if ([value isKindOfClass:[CLLocation class]]) {
            value = [value convertToJSONObject];
        }
        [converted setValue:value forKey:key];
    }
    return converted;
}

+ (NSDictionary *)convertProperties:(NSDictionary *)prop {
    NSMutableDictionary *converted = [NSMutableDictionary dictionary];
    for(id key in prop) {
        id value = [prop objectForKey:key];
        if ([value isKindOfClass:[NSDate class]]) {
            value = [value convertToJSONString];
        } else if ([value isKindOfClass:[NSData class]]) {
            value = [value convertToJSONObject];
        } else if ([value isKindOfClass:[CLLocation class]]) {
            value = [value convertToJSONObject];
        }
        [converted setValue:value forKey:key];
    }
    return converted;
}

+ (NSDate *)dateFromEncodedArgument:(NSDictionary *)value {

    if ([value count] != 2 ||
        ![(NSString *)(value[@"$type"]) isEqualToString:@"date"] ||
        ![value[@"$data"] isKindOfClass:[NSString class]]) {

        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:
                                               @"Argument doesn't follow the Date serialization format: %@",
                                               value]
                                     userInfo:nil];
    }
    NSString *dateString = (NSString *)value[@"$data"];
    NSDate *date = [NSDate dateFromJSONString:dateString];
    return date;
}

+ (NSData *)dataFromEncodedArgument:(NSDictionary *)value {

    if ([value count] != 2 ||
        ![(NSString *)(value[@"$type"]) isEqualToString:@"base64"] ||
        ![value[@"$data"] isKindOfClass:[NSString class]]) {

        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:[NSString stringWithFormat:
                                               @"Argument doesn't follow the Buffer serialization format: %@",
                                               value]
                                     userInfo:nil];
    }
    NSString *base64String = (NSString *)value[@"$data"];
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64String options:0];
    return data;
}

+ (CLLocation *)locationFromEncodedArgument:(NSDictionary *)value {
    return [CLLocation locationFromJSONObject:value];
}

+ (NSDate *)dateFromEncodedProperty:(NSString *)value {
    return [NSDate dateFromJSONString:value];
}

+ (NSMutableData *)dataFromEncodedProperty:(NSDictionary *)value {
    return [NSMutableData dataFromJSONObject:value];
}

+ (CLLocation *)locationFromEncodedProperty:(NSDictionary *)value {
    return [CLLocation locationFromJSONObject:value];
}

@end

@implementation SLRepository

+ (instancetype)repositoryWithClassName:(NSString *)name {
    return [[self alloc] initWithClassName:name];
}

- (instancetype)initWithClassName:(NSString *)name {
    self = [super init];

    if (self) {
        self.className = name;
    }

    return self;
}

- (SLObject *)objectWithParameters:(NSDictionary *)parameters {
    return [SLObject objectWithRepository:self parameters:parameters];
}

- (void)invokeStaticMethod:(NSString *)name
                parameters:(NSDictionary *)parameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {

    NSString *path = [NSString stringWithFormat:@"%@.%@", self.className, name];
    [self.adapter invokeStaticMethod:path
                          parameters:[SLObject convertArguments:parameters]
                      bodyParameters:nil
                        outputStream:nil
                             success:success
                             failure:failure];
}

- (void)invokeStaticMethod:(NSString *)name
                parameters:(NSDictionary *)parameters
            bodyParameters:(NSDictionary *)bodyParameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {

    NSString *path = [NSString stringWithFormat:@"%@.%@", self.className, name];
    [self.adapter invokeStaticMethod:path
                          parameters:[SLObject convertArguments:parameters]
                      bodyParameters:[SLObject convertProperties:bodyParameters]
                        outputStream:nil
                             success:success
                             failure:failure];
}

- (void)invokeStaticMethod:(NSString *)name
                parameters:(NSDictionary *)parameters
              outputStream:(NSOutputStream *)outputStream
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {

    NSString *path = [NSString stringWithFormat:@"%@.%@", self.className, name];
    [self.adapter invokeStaticMethod:path
                          parameters:[SLObject convertArguments:parameters]
                      bodyParameters:nil
                        outputStream:outputStream
                             success:success
                             failure:failure];
}

@end
