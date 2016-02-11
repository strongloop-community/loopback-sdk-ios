/**
 * @file LBModel.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLRemoting.h"


/**
 * A local representative of a single model instance on the server. The data is
 * immediately accessible locally.
 */
@interface LBModel : SLObject 

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

@end

/**
 * A local representative of a single model type on the server, encapsulating
 * the name of the model type for easy LBModel creation, discovery, and
 * management.
 */
@interface LBModelRepository : SLRepository

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
 * Creates a new LBModel of this type without setting initial parameters.
 *
 * @return  A new LBModel.
 */
- (LBModel *)model;

/**
 * Creates a new LBModel of this type with the parameters described.
 *
 * @param  dictionary The data to encapsulate.
 * @return            A new LBModel.
 */
- (LBModel *)modelWithDictionary:(NSDictionary *)dictionary;

@end
