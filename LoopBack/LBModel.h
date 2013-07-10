//
//  LBModel.h
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLRemoting.h"

@interface LBModel : SLObject

- (id)objectAtKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

//typedef void (^LBModelSaveSuccessBlock)();
//- (void)save:(LBModelSaveSuccessBlock)success
//     failure:(SLFailureBlock)failure;
//
//typedef void (^LBModelDestroySuccessBlock)();
//- (void)destroy:(LBModelDestroySuccessBlock)success
//        failure:(SLFailureBlock)failure;

@end

@interface LBModelPrototype : SLPrototype

@property Class modelClass;

- (SLRESTContract *)contract;

- (LBModel *)modelWithDictionary:(NSDictionary *)dictionary;

//typedef void (^LBModelExistsSuccessBlock)(BOOL exists);
//- (void)existsWithId:(NSNumber *)_id
//             success:(LBModelExistsSuccessBlock)success
//             failure:(SLFailureBlock)failure;

typedef void (^LBModelFindSuccessBlock)(LBModel *model);
- (void)findWithId:(NSNumber *)_id
           success:(LBModelFindSuccessBlock)success
           failure:(SLFailureBlock)failure;

typedef void (^LBModelAllSuccessBlock)(NSArray *models);
- (void)allWithSuccess:(LBModelAllSuccessBlock)success
               failure:(SLFailureBlock)failure;

//typedef void (^LBModelFindOneSuccessBlock)(LBModel *model);
//- (void)findOneWithFilter:(NSDictionary *)filter
//                  success:(LBModelFindOneSuccessBlock)success
//                  failure:(SLFailureBlock)failure;

@end
