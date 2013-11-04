/**
 * @file LBModel.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "LBModel.h"

#import <objc/runtime.h>

#define NSSelectorForSetter(key) NSSelectorFromString([NSString stringWithFormat:@"set%@:", [key capitalizedString]])


@interface LBModel() {
    NSMutableDictionary *__overflow;
}

@property (nonatomic, readwrite, copy) NSNumber *_id;

- (NSMutableDictionary *)_overflow;
- (void)setId:(NSNumber *)_id;

@end

@implementation LBModel

- (instancetype)initWithRepository:(SLRepository *)repository parameters:(NSDictionary *)parameters {
    self = [super initWithRepository:repository parameters:parameters];

    if (self) {
        __overflow = [NSMutableDictionary dictionary];
    }

    return self;
}

- (id)objectForKeyedSubscript:(id <NSCopying>)key {
    return [__overflow objectForKey:key];
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key {
    [__overflow setObject:obj forKey:key];
}

- (NSMutableDictionary *)_overflow {
    return __overflow;
}

- (void)setId:(NSNumber *)_id {
    __id = _id;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:__overflow];

    [dict setValue:__id forKey:@"id"];

    unsigned int propertyCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    NSString *propertyName;

    for (i = 0; i < propertyCount; i++) {
        propertyName = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
        if ([propertyName isEqualToString:@"_id"]) {
            continue;
        }

        [dict setValue:[self valueForKey:propertyName] forKey:propertyName];
    }

    return dict;
}

- (void)saveWithSuccess:(LBModelSaveSuccessBlock)success
                failure:(SLFailureBlock)failure {
    [self invokeMethod:self._id ? @"save" : @"create"
            parameters:[self toDictionary]
               success:^(id value) {
                   self._id = [value valueForKey:@"id"];
                   success();
               }
               failure:failure];
}

- (void)destroyWithSuccess:(LBModelDestroySuccessBlock)success
                   failure:(SLFailureBlock)failure {
    [self invokeMethod:@"remove"
            parameters:[self toDictionary]
               success:^(id value) {
                   success();
               }
               failure:failure];
}

@end

@implementation LBModelRepository

- (instancetype)initWithClassName:(NSString *)name {
    self = [super initWithClassName:name];

    if (self) {
        NSString *modelClassName = NSStringFromClass([self class]);
        const int strlenOfRepository = 10;
        modelClassName = [modelClassName substringWithRange:NSMakeRange(0, [modelClassName length] - strlenOfRepository)];

        self.modelClass = NSClassFromString(modelClassName);
        if (!self.modelClass) {
            self.modelClass = [LBModel class];
        }
    }

    return self;
}

- (SLRESTContract *)contract {
    SLRESTContract *contract = [SLRESTContract contract];

    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@", self.className] verb:@"POST"]
            forMethod:[NSString stringWithFormat:@"%@.prototype.create", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:id", self.className] verb:@"PUT"]
            forMethod:[NSString stringWithFormat:@"%@.prototype.save", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:id", self.className] verb:@"DELETE"]
            forMethod:[NSString stringWithFormat:@"%@.prototype.remove", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:id", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.findById", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.all", self.className]];

    return contract;
}

- (LBModel *)modelWithDictionary:(NSDictionary *)dictionary {
    LBModel __block *model = (LBModel *)[[self.modelClass alloc] initWithRepository:self parameters:dictionary];

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
           success:(LBModelFindSuccessBlock)success
           failure:(SLFailureBlock)failure {
    [self invokeStaticMethod:@"findById"
                  parameters:@{ @"id": _id }
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         success([self modelWithDictionary:value]);
                     } failure:failure];
}

- (void)allWithSuccess:(LBModelAllSuccessBlock)success
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
