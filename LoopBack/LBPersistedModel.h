/**
 * @file LBPersistedModel.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "LBModel.h"


/**
 * Blocks of this type are executed for a successful method invocation that returns
 * an LBPersistedModel instance as a callback argument.
 */
@class LBPersistedModel;
typedef void (^LBPersistedModelObjectSuccessBlock)(LBPersistedModel *model);

// The following typedefs are left for backward compatibility.
typedef LBModelVoidSuccessBlock     LBPersistedModelVoidSuccessBlock
        __attribute((deprecated("use LBModelVoidSuccessBlock")));
typedef LBModelBoolSuccessBlock     LBPersistedModelBoolSuccessBlock
        __attribute((deprecated("use LBModelBoolSuccessBlock")));
typedef LBModelNumberSuccessBlock   LBPersistedModelNumberSuccessBlock
        __attribute((deprecated("use LBModelNumberSuccessBlock")));
typedef LBModelArraySuccessBlock    LBPersistedModelArraySuccessBlock
        __attribute((deprecated("use LBModelArraySuccessBlock")));

/**
 * A local representative of a single persisted model instance on the server.
 * The key difference from LBModel is that this implements the CRUD operation supports.
 */
@interface LBPersistedModel : LBModel

/** All Models have a numerical `id` field. */
@property (nonatomic, readonly, copy) id _id;

/**
 * Blocks of this type are executed when LBPersistedModel::saveWithSuccess:failure: is
 * successful.
 */
typedef LBModelVoidSuccessBlock LBPersistedModelSaveSuccessBlock;
/**
 * Saves the LBPersistedModel to the server.
 *
 * Calls `toDictionary` to determine which fields should be saved.
 *
 * @param success  The block to be executed when the save is successful.
 * @param failure  The block to be executed when the save fails.
 */
- (void)saveWithSuccess:(LBPersistedModelSaveSuccessBlock)success
                failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when LBPersistedModel::destroyWithSuccess:failure: is
 * successful.
 */
typedef LBModelVoidSuccessBlock LBPersistedModelDestroySuccessBlock;
/**
 * Destroys the LBPersistedModel from the server.
 *
 * @param success  The block to be executed when the destroy is successful.
 * @param failure  The block to be executed when the destroy fails.
 */
- (void)destroyWithSuccess:(LBPersistedModelDestroySuccessBlock)success
                   failure:(SLFailureBlock)failure;

@end

/**
 * A local representative of a single model type on the server, encapsulating
 * the name of the model type for easy LBPersistedModel creation, discovery, and
 * management.
 */
@interface LBPersistedModelRepository : LBModelRepository

//typedef void (^LBPersistedModelExistsSuccessBlock)(BOOL exists);
//- (void)existsWithId:(id)_id
//             success:(LBPersistedModelExistsSuccessBlock)success
//             failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBModelRepository::findById:success:failure: is successful.
 */
typedef LBPersistedModelObjectSuccessBlock LBPersistedModelFindSuccessBlock;
/**
 * Finds and downloads a single instance of this model type on and from the
 * server with the given id.
 *
 * @param _id      The id to search for.
 * @param success  The block to be executed when the destroy is successful.
 * @param failure  The block to be executed when the destroy fails.
 */
- (void)findById:(id)_id
         success:(LBPersistedModelFindSuccessBlock)success
         failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBPersistedModelRepository::allWithSuccess:failure: is successful.
 */
typedef LBModelArraySuccessBlock LBPersistedModelAllSuccessBlock;
/**
 * Finds and downloads all models of this type on and from the server.
 *
 * @param success  The block to be executed when the destroy is successful.
 * @param failure  The block to be executed when the destroy fails.
 */
- (void)allWithSuccess:(LBPersistedModelAllSuccessBlock)success
               failure:(SLFailureBlock)failure;

typedef LBPersistedModelObjectSuccessBlock LBPersistedModelFindOneSuccessBlock;
- (void)findOneWithFilter:(NSDictionary *)filter
                  success:(LBPersistedModelFindOneSuccessBlock)success
                  failure:(SLFailureBlock)failure;

- (void)findWithFilter:(NSDictionary *)filter
                  success:(LBPersistedModelAllSuccessBlock)success
                  failure:(SLFailureBlock)failure;

@end
