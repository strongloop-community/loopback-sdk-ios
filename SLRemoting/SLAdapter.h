/**
 * @file SLAdapter.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * Blocks of this type are executed for any successful method invocation, i.e.
 * one where the remote method called the callback as `callback(null, value)`.
 *
 * **Example:**
 * @code
 * [...
 *     success:^(id value) {
 *         NSLog(@"The result was: %@", value);
 *     }
 * ...];
 * @endcode
 *
 * @param value  The top-level value returned by the remote method, typed
 *               appropriately: an NSNumber for all Numbers, an
 *               NSDictionary for all Objects, etc.
 */
typedef void (^SLSuccessBlock)(id value);

/**
 * Blocks of this type are executed for any failed method invocation, i.e. one
 * where the remote method called the callback as `callback(error, null)` or
 * just `callback(error)`.
 *
 * **Example:**
 * @code
 * [...
 *     success:^(id value) {
 *         NSLog(@"The result was: %@", value);
 *     }
 * ...];
 * @endcode
 *
 * @param error  The error received, as a properly-formatted
 *               NSError.
 */
typedef void (^SLFailureBlock)(NSError *error);

/**
 * An error description for SLAdapters that are not connected to any server.
 * Errors with this description will be passed to the SLFailureBlock associated
 * with a request made of a disconnected Adapter.
 */
extern NSString *SLAdapterNotConnectedErrorDescription;

/**
 * The entry point to all networking accomplished with LoopBack. Adapters
 * encapsulate information consistent to all networked operations, such as base
 * URL, port, etc.
 */
@interface SLAdapter : NSObject

/** YES if the SLAdapter is connected to a server, NO otherwise. */
@property (readonly, nonatomic) BOOL connected;

/** A flag to control if invalid SSL certificates are allowed */
@property (readonly, nonatomic) BOOL allowsInvalidSSLCertificate;

/**
 * Returns a new, disconnected Adapter.
 *
 * @return A disconnected Adapter.
 */
+ (instancetype)adapter;

/**
 * Returns a new Adapter connected to `url`.
 *
 * @param  url  The URL to connect to.
 * @return      A connected Adapter.
 */
+ (instancetype)adapterWithURL:(NSURL *)url;

/**
 * Returns a new Adapter connected to `url`.
 *
 * @param  url  The URL to connect to.
 * @param  allowsInvalidSSLCertificate  Is invalid SSL certificate allowed?
 * @return      A connected Adapter.
 */
+ (instancetype)adapterWithURL:(NSURL *)url allowsInvalidSSLCertificate : (BOOL) allowsInvalidSSLCertificate;

/**
 * Initializes a new Adapter, connecting it to `url`.
 *
 * @param  url  The URL to connect to.
 * @return      The connected Adapter.
 */
- (instancetype)initWithURL:(NSURL *)url allowsInvalidSSLCertificate : (BOOL) allowsInvalidSSLCertificate ;

/**
 * Connects the Adapter to `url`.
 *
 * @param url  The URL to connect to.
 */
- (void)connectToURL:(NSURL *)url;

/**
 * Invokes a remotable method exposed statically on the server.
 *
 * Unlike SLAdapter::invokeInstanceMethod:constructorParameters:parameters:success:failure:,
 * no object needs to be created on the server.
 *
 * @param method      The method to invoke, e.g. `module.doSomething`.
 * @param parameters  The parameters to invoke with.
 * @param success     An SLSuccessBlock to be executed when the invocation
 *                    succeeds.
 * @param failure     An SLFailureBlock to be executed when the invocation
 *                    fails.
 */
- (void)invokeStaticMethod:(NSString *)method
                parameters:(NSDictionary *)parameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure;

/**
 * Invokes a remotable method exposed within a prototype on the server.
 *
 * This should be thought of as a two-step process. First, the server loads or
 * creates an object with the appropriate type. Then and only then is the method
 * invoked on that object. The two parameter dictionaries correspond to these
 * two steps: `creationParameters` for the former, and `parameters` for the
 * latter.
 *
 * @param method                 The method to invoke, e.g.
 *                               `MyClass.prototype.doSomething`.
 * @param constructorParameters  The parameters the virual object should be
 *                               created with.
 * @param parameters             The parameters to invoke with.
 * @param success                An SLSuccessBlock to be executed when the
 *                               invocation succeeds.
 * @param failure                An SLFailureBlock to be executed when the
 *                               invocation fails.
 */
- (void)invokeInstanceMethod:(NSString *)method
       constructorParameters:(NSDictionary *)constructorParameters
                  parameters:(NSDictionary *)parameters
                     success:(SLSuccessBlock)success
                     failure:(SLFailureBlock)failure;

@end
