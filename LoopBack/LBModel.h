//
//  LBModel.h
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <SLRemoting/SLRemoting.h>

@interface LBModel : SLObject

@property (nonatomic, readonly, copy) NSNumber *_id;

- (id)objectForKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

- (NSDictionary *)toDictionary;

typedef void (^LBModelSaveSuccessBlock)();
- (void)saveWithSuccess:(LBModelSaveSuccessBlock)success
                failure:(SLFailureBlock)failure;

typedef void (^LBModelDestroySuccessBlock)();
- (void)destroyWithSuccess:(LBModelDestroySuccessBlock)success
                   failure:(SLFailureBlock)failure;

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
