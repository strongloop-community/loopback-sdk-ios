/**
 * @file SLRESTContract.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import <Foundation/Foundation.h>

/** The verb SLRemoting uses when no verb has been specified by the server. */
extern NSString *SLRESTContractDefaultVerb;

/**
 * A single item within a larger SLRESTContract, encapsulation a single route's
 * verb and pattern, e.g. GET /widgets/:id.
 */
@interface SLRESTContractItem : NSObject

/** The pattern corresponding to this route, e.g. `/widgets/:id`. */
@property (readonly, nonatomic, copy) NSString *pattern;
/** The verb corresponding to this route, e.g. `GET`. */
@property (readonly, nonatomic, copy) NSString *verb;
/** Indication that this item is a multipart form mime type. */
@property (readonly, nonatomic, assign) BOOL multipart;

/**
 * Returns a new item encapsulating the given pattern.
 *
 * @param  pattern  The pattern to represent.
 * @return          A new item.
 */
+ (instancetype)itemWithPattern:(NSString *)pattern;

/**
 * Initializes a new item to encapsulate the given pattern.
 *
 * @param  pattern  The pattern to represent.
 * @return          The item.
 */
- (instancetype)initWithPattern:(NSString *)pattern;

/**
 * Returns a new item encapsulating the given pattern and verb.
 *
 * @param  pattern  The pattern to represent.
 * @param  verb     The verb to represent.
 * @return          A new item.
 */
+ (instancetype)itemWithPattern:(NSString *)pattern verb:(NSString *)verb;

/**
 * Initializes a new item encapsulating the given pattern and verb.
 *
 * @param  pattern  The pattern to represent.
 * @param  verb     The verb to represent.
 * @return          A new item.
 */
- (instancetype)initWithPattern:(NSString *)pattern verb:(NSString *)verb;

/**
 * Returns a new item encapsulating the given pattern, verb and multipart setting.
 *
 * @param  pattern   The pattern to represent.
 * @param  verb      The verb to represent.
 * @param multiplart Indicates this item is a multipart mime type.
 * @return           A new item.
 */
+ (instancetype)itemWithPattern:(NSString *)pattern verb:(NSString *)verb multipart:(BOOL)multipart;

/**
 * Initializes a new item encapsulating the given pattern and verb.
 *
 * @param  pattern   The pattern to represent.
 * @param  verb      The verb to represent.
 * @param multiplart Indicates this item is a multipart mime type.
 * @return           A new item.
 */
- (instancetype)initWithPattern:(NSString *)pattern verb:(NSString *)verb multipart:(BOOL)multipart;

@end

/**
 * A contract specifies how remote method names map to HTTP routes.
 *
 * For example, if a remote method on the server has been remapped like so:
 *
 * @code{.js}
 * project.getObject = function (id, callback) {
 *     callback(null, { ... });
 * };
 * helper.method(project.getObject, {
 *     http: { verb: 'GET', path: '/:id'},
 *     accepts: { name: 'id', type: 'string' }
 *     returns: { name: 'object', type: 'object' }
 * })
 * @endcode
 *
 * The new route is GET /:id, instead of POST /project/getObject, so we
 * need to update our contract on the client:
 *
 * @code{.m}
 * [contract addItem:[SLRESTContractItem itemWithPattern:@"/:id" verb:@"GET"]
 *     forMethod:@"project.getObject"];
 * @endcode
 */
@interface SLRESTContract : NSObject

/**
 * A read-only representation of the internal contract. Used for
 * SLRESTContract::addItemsFromContract:.
 */
@property (readonly, nonatomic) NSDictionary *dict;

/**
 * Returns a new, empty contract.
 *
 * @return A new, empty contract.
 */
+ (instancetype)contract;

/**
 * Adds a single item to this contract. The item can be shared among different
 * contracts, managed by the sum of all contracts that contain it. Similarly,
 * each item can be used for more than one method, like so:
 *
 * @code{.m}
 * SLRESTContractItem *upsert = [SLRESTContractItem itemWithPattern:@"/widgets/:id"
 *                                                        andVerb:@"PUT"];
 * [contract addItem:upsert forMethod:@"widgets.create"];
 * [contract addItem:upsert forMethod:@"widgets.update"];
 * @endcode
 *
 * @param item   The item to add to this contract.
 * @param method The method the item should represent.
 */
- (void)addItem:(SLRESTContractItem *)item forMethod:(NSString *)method;

/**
 * Adds all items from contract.
 *
 * @see addItem:forMethod:
 *
 * @param contract The contract to copy from.
 */
- (void)addItemsFromContract:(SLRESTContract *)contract;

/**
 * Resolves a specific method, replacing pattern fragments with the optional
 * `parameters` as appropriate.
 *
 * @param  method     The method to resolve.
 * @param  parameters Pattern parameters. Can be `nil`.
 * @return            The complete, resolved URL.
 */
- (NSString *)urlForMethod:(NSString *)method
                parameters:(NSDictionary *)parameters;

/**
 * Returns the HTTP verb for the given method string.
 *
 * @param  method The method to resolve.
 * @return        The resolved verb.
 */
- (NSString *)verbForMethod:(NSString *)method;

/**
 * Returns the multipart setting for the given method string.
 *
 * @param  method The method to resolve.
 * @return        The mutipart setting.
 */
- (BOOL)multipartForMethod:(NSString *)method;

/**
 * Generates a fallback URL for a method whose contract has not been customized.
 *
 * @param  method The method to generate from.
 * @return        The resolved URL.
 */
- (NSString *)urlForMethodWithoutItem:(NSString *)method;

/**
 * Returns the custom pattern representing the given method string, or `nil` if
 * no custom pattern exists.
 *
 * @param  method The method to resolve.
 * @return        The custom pattern if one exists, `nil` otherwise.
 */
- (NSString *)patternForMethod:(NSString *)method;

/**
 * Returns a rendered URL pattern using the parameters provided. For example,
 * `@"/widgets/:id"` + `@{ @"id": "57", @"price": @"42.00" }` begets
 * `@"/widgets/57"`.
 *
 * @param  pattern    The pattern to render.
 * @param  parameters Values to render with.
 * @return            The rendered URL.
 */
- (NSString *)urlWithPattern:(NSString *)pattern
                  parameters:(NSDictionary *)parameters;

@end
