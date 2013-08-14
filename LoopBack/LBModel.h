/**
 * @file LBModel.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import <LoopBack/SLRemoting.h>

/**
 * A local representative of a single model instance on the server. The data is
 * immediately accessible locally, but can be saved, destroyed, etc. from the
 * server easily.
 */
@interface LBModel : SLObject

/** All Models have a numerical `id` field. */
@property (nonatomic, readonly, copy) NSNumber *_id;

/**
 * Returns the value associated with a given key.
 *
 * Used for NSDictionary-like subscripting:
 * @code{.m}
 * NSLog(somemodel[@"key"]);
 * @endcode
 *
 * @param  key  The key for which to return the corresponding value.
 * @return      The value associated with `key`, or `nil` if no value is
 *              associated with `key`.
 */
- (id)objectForKeyedSubscript:(id <NSCopying>)key;

/**
 * Adds a given key-value pair to the dictionary.
 *
 * Used for NSDictionary-like subscripting:
 * @code{.m}
 * somemodel[@"key"] = @"value";
 * @endcode
 *
 * @param obj  The value for aKey. A strong reference to the object is
 *             maintained by the dictionary. Raises an
 *             NSInvalidArgumentException if anObject is nil. If you need to
 *             represent a nil value in the dictionary, use NSNull.
 * @param key  The key for value. The key is copied (using copyWithZone:; keys
 *             must conform to the NSCopying protocol). Raises an
 *             NSInvalidArgumentException if aKey is nil. If aKey already exists
 *             in the dictionary anObject takes its place.
 */
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

/**
 * Converts the LBModel (and all of its \@properties) into an NSDictionary.
 *
 * toDictionary should be overridden in child classes that wish to change this
 * behaviour: hiding properties, adding computed properties, etc.
 */
- (NSDictionary *)toDictionary;

/**
 * Blocks of this type are executed when LBModel::saveWithSuccess:failure: is
 * successful.
 */
typedef void (^LBModelSaveSuccessBlock)();
/**
 * Saves the LBModel to the server.
 *
 * Calls `toDictionary` to determine which fields should be saved.
 *
 * @param success  The block to be executed when the save is successful.
 * @param failure  The block to be executed when the save fails.
 */
- (void)saveWithSuccess:(LBModelSaveSuccessBlock)success
                failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when LBModel::destroyWithSuccess:failure: is
 * successful.
 */
typedef void (^LBModelDestroySuccessBlock)();
/**
 * Destroys the LBModel from the server.
 *
 * @param success  The block to be executed when the destroy is successful.
 * @param failure  The block to be executed when the destroy fails.
 */
- (void)destroyWithSuccess:(LBModelDestroySuccessBlock)success
                   failure:(SLFailureBlock)failure;

@end

/**
 * A local representative of a single model type on the server, encapsulating
 * the name of the model type for easy LBModel creation, discovery, and
 * management.
 */
@interface LBModelPrototype : SLPrototype

/** The LBModel subclass used to wrap model instances. */
@property Class modelClass;

/**
 * The SLRESTContract representing this model type's custom routes. Used to
 * extend an Adapter to support this model type.
 *
 * @return A shared SLRESTContract for this model type.
 */
- (SLRESTContract *)contract;

/**
 * Creates a new LBModel of this type with the parameters described.
 *
 * @param  dictionary The data to encapsulate.
 * @return            A new LBModel.
 */
- (LBModel *)modelWithDictionary:(NSDictionary *)dictionary;

//typedef void (^LBModelExistsSuccessBlock)(BOOL exists);
//- (void)existsWithId:(NSNumber *)_id
//             success:(LBModelExistsSuccessBlock)success
//             failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBModelPrototype::findWithId:success:failure: is successful.
 */
typedef void (^LBModelFindSuccessBlock)(LBModel *model);
/**
 * Finds and downloads a single instance of this model type on and from the
 * server with the given id.
 *
 * @param _id      The id to search for.
 * @param success  The block to be executed when the destroy is successful.
 * @param failure  The block to be executed when the destroy fails.
 */
- (void)findWithId:(NSNumber *)_id
           success:(LBModelFindSuccessBlock)success
           failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBModelPrototype::allWithSuccess:failure: is successful.
 */
typedef void (^LBModelAllSuccessBlock)(NSArray *models);
/**
 * Finds and downloads all models of this type on and from the server.
 *
 * @param success  The block to be executed when the destroy is successful.
 * @param failure  The block to be executed when the destroy fails.
 */
- (void)allWithSuccess:(LBModelAllSuccessBlock)success
               failure:(SLFailureBlock)failure;

//typedef void (^LBModelFindOneSuccessBlock)(LBModel *model);
//- (void)findOneWithFilter:(NSDictionary *)filter
//                  success:(LBModelFindOneSuccessBlock)success
//                  failure:(SLFailureBlock)failure;

@end
