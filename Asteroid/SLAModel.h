//
//  SLAModel.h
//  Asteroid
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLRemoting.h"

@interface SLAModel : SLObject

- (id)objectAtKeyedSubscript:(id <NSCopying>)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

//typedef void (^SLAModelSaveSuccessBlock)();
//- (void)save:(SLAModelSaveSuccessBlock)success
//     failure:(SLFailureBlock)failure;
//
//typedef void (^SLAModelDestroySuccessBlock)();
//- (void)destroy:(SLAModelDestroySuccessBlock)success
//        failure:(SLFailureBlock)failure;

@end

@interface SLAModelPrototype : SLPrototype

@property Class modelClass;

- (SLRESTContract *)contract;

- (SLAModel *)modelWithDictionary:(NSDictionary *)dictionary;

//typedef void (^SLAModelExistsSuccessBlock)(BOOL exists);
//- (void)existsWithId:(NSNumber *)_id
//             success:(SLAModelExistsSuccessBlock)success
//             failure:(SLFailureBlock)failure;
//
//typedef void (^SLAModelFindSuccessBlock)(SLAModel *model);
//- (void)findWithId:(NSNumber *)_id
//           success:(SLAModelFindSuccessBlock)success
//           failure:(SLFailureBlock)failure;

typedef void (^SLAModelAllSuccessBlock)(NSArray *models);
- (void)allWithSuccess:(SLAModelAllSuccessBlock)success
               failure:(SLFailureBlock)failure;

//typedef void (^SLAModelFindOneSuccessBlock)(SLAModel *model);
//- (void)findOneWithFilter:(NSDictionary *)filter
//                  success:(SLAModelFindOneSuccessBlock)success
//                  failure:(SLFailureBlock)failure;

@end
