/**
 * @file LBModel.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import <objc/runtime.h>

#import "LBModel.h"


@interface LBModel() {
    NSMutableDictionary *__overflow;
}

- (NSMutableDictionary *)_overflow;

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

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:__overflow];

    for (Class targetClass = [self class]; targetClass != [LBModel superclass]; targetClass = [targetClass superclass]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(targetClass, &propertyCount);

        for (int i = 0; i < propertyCount; i++) {
            NSString *propertyName = [NSString stringWithCString:property_getName(properties[i])
                                                        encoding:NSUTF8StringEncoding];
            id obj = [self valueForKey:propertyName];
            [dict setValue:obj forKey:propertyName];
        }
        free(properties);
    }

    return dict;
}

- (NSString *)description {
    return [NSString stringWithFormat: @"<%@ %@>", NSStringFromClass([self class]), [self toDictionary]];
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
    return contract;
}

- (LBModel *)model {
    LBModel *model = (LBModel *)[[self.modelClass alloc] initWithRepository:self parameters:nil];
    return model;
}

- (LBModel *)modelWithDictionary:(NSDictionary *)dictionary {
    LBModel *model = (LBModel *)[[self.modelClass alloc] initWithRepository:self parameters:dictionary];

    [[model _overflow] addEntriesFromDictionary:dictionary];

    for (Class targetClass = [model class]; targetClass != [LBModel superclass]; targetClass = [targetClass superclass]) {
        unsigned int count;
        objc_property_t* props = class_copyPropertyList(targetClass, &count);
        for (int i = 0; i < count; i++) {
            objc_property_t property = props[i];
            const char *name = property_getName(property);
            NSString *key = [NSString stringWithUTF8String:name];
            id obj = dictionary[key];
            if (obj == nil) {
                continue;
            }

            const char *type = property_getAttributes(property);
            if ([obj isKindOfClass:[NSString class]]) {
                // if the property type is NSDate, convert the string to a date object
                if (strncmp(type, "T@\"NSDate\",", 11) == 0) {
                    obj = [SLObject dateFromEncodedProperty:obj];
                }
            } else if ([obj isKindOfClass:[NSDictionary class]]) {
                // if the property type is NSMutableData, convert the json object to a data object
                if (strncmp(type, "T@\"NSMutableData\",", 18) == 0 ||
                    strncmp(type, "T@\"NSData\",", 11) == 0) {
                    obj = [SLObject dataFromEncodedProperty:obj];
                }
                // if the property type is CLLocation, convert the json object to a location object
                else if (strncmp(type, "T@\"CLLocation\",", 15) == 0) {
                    obj = [SLObject locationFromEncodedProperty:obj];
                }
            }

            @try {
                [model setValue:obj forKey:key];
            }
            @catch (NSException *e) {
                // ignore any failure
            }
        }
        free(props);
    }

    return model;
}

@end
