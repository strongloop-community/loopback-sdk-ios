/**
 * @file LBPersistedModel.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "LBPersistedModel.h"


@interface LBPersistedModel() {
    id __id;
}

- (void)setId:(id)_id;

@end

@implementation LBPersistedModel

@synthesize _id = __id;

- (void)setId:(id)_id {
    __id = [_id copy];
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dict = (NSMutableDictionary *)[super toDictionary];
    [dict removeObjectForKey:@"_id"];
    [dict setValue:__id forKey:@"id"];

    return dict;
}

- (void)saveWithSuccess:(LBPersistedModelSaveSuccessBlock)success
                failure:(SLFailureBlock)failure {
    [self invokeMethod:self._id ? @"save" : @"create"
            parameters:self._id ? @{ @"id": self._id } : nil
        bodyParameters:[self toDictionary]
               success:^(id value) {
                   [self setId:[value valueForKey:@"id"]];
                   success();
               }
               failure:failure];
}

- (void)destroyWithSuccess:(LBPersistedModelDestroySuccessBlock)success
                   failure:(SLFailureBlock)failure {
    [self invokeMethod:@"remove"
            parameters:@{ @"id": self._id }
               success:^(id value) {
                   success();
               }
               failure:failure];
}

@end

@implementation LBPersistedModelRepository

- (SLRESTContract *)contract {
    SLRESTContract *contract = [super contract];

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
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.find", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/findOne", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.findOne", self.className]];

    return contract;
}

- (LBModel *)modelWithDictionary:(NSDictionary *)dictionary {
    LBModel *model = [super modelWithDictionary:dictionary];
    id obj = dictionary[@"id"];
    if (obj) {
        [(LBPersistedModel *)model setId:obj];
    }
    return model;
}

- (void)findById:(id)_id
         success:(LBPersistedModelFindSuccessBlock)success
         failure:(SLFailureBlock)failure {
    NSParameterAssert(_id);
    [self invokeStaticMethod:@"findById"
                  parameters:@{ @"id": _id }
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         success((LBPersistedModel*)[self modelWithDictionary:value]);
                     } failure:failure];
}

- (void)allWithSuccess:(LBPersistedModelAllSuccessBlock)success
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

- (void)findOneWithFilter:(NSDictionary *)filter
        success:(LBPersistedModelFindOneSuccessBlock)success
        failure:(SLFailureBlock)failure {

    if(!filter) {
        filter = @{};
    }
    [self invokeStaticMethod:@"findOne"
                  parameters:@{@"filter": filter}
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         success((LBPersistedModel*)[self modelWithDictionary:value]);
                     } failure:failure];
}

- (void)findWithFilter:(NSDictionary *) filter
                success: (LBPersistedModelAllSuccessBlock)success
                failure:(SLFailureBlock)failure {
    if(!filter) {
        filter = @{};
    }
    [self invokeStaticMethod:@"find"
                  parameters:@{@"filter": filter}
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
