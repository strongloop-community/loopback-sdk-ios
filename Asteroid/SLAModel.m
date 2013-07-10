//
//  SLAModel.m
//  Asteroid
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLAModel.h"

#define NSSelectorForSetter(key) NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key capitalizedString]])


@interface SLAModel() {
    NSMutableDictionary *__overflow;
}

- (NSMutableDictionary *)_overflow;

@end

@implementation SLAModel

- (instancetype)init {
    self = [super init];

    if (self) {
        __overflow = [NSMutableDictionary dictionary];
    }

    return self;
}

- (id)objectAtKeyedSubscript:(id <NSCopying>)key {
    NSLog(@"RTS: %i", [self respondsToSelector:@selector(key)]);

    return [__overflow objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    [__overflow setObject:obj forKey:key];
}

- (NSMutableDictionary *)_overflow {
    return __overflow;
}

@end

@implementation SLAModelPrototype

- (instancetype)initWithName:(NSString *)name {
    self = [super initWithName:name];

    if (self) {
        NSString *modelClassName = NSStringFromClass([self class]);
        modelClassName = [modelClassName substringWithRange:NSMakeRange(0, [modelClassName length] - 9)];

        self.modelClass = NSClassFromString(modelClassName);
        if (!self.modelClass) {
            self.modelClass = [SLAModel class];
        }
    }

    return self;
}

- (SLRESTContract *)contract {
    SLRESTContract *contract = [SLRESTContract contract];

    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:id", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.findById", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/all", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.all", self.className]];

    return contract;
}

- (SLAModel *)modelWithDictionary:(NSDictionary *)dictionary {
    SLAModel __block *model = (SLAModel *)[[self.modelClass alloc] init];

    [[model _overflow] addEntriesFromDictionary:dictionary];

    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        SEL setter = NSSelectorForSetter(key);

        if ([model respondsToSelector:setter]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [model performSelector:setter withObject:obj];
#pragma clang diagnostic pop
        }
    }];

    return model;
}

- (void)findWithId:(NSNumber *)_id
           success:(SLAModelFindSuccessBlock)success
           failure:(SLFailureBlock)failure {
    [self invokeStaticMethod:@"findById"
                  parameters:@{ @"id": _id }
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         success([self modelWithDictionary:value]);
                     } failure:failure];
}

- (void)allWithSuccess:(SLAModelAllSuccessBlock)success
               failure:(SLFailureBlock)failure {
    [self invokeStaticMethod:@"all"
                  parameters:@{}
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSArray class]], @"Received non-Array: %@", value);

                         NSMutableArray *models = [NSMutableArray array];

                         [value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                             [models addObject:[self modelWithDictionary:obj]];
                         }];

                         success(models);
                     }
                     failure:failure];
}

@end