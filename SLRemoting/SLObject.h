/**
 * @file SLObject.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import <Foundation/Foundation.h>

#import "SLAdapter.h"

/**
 * An error description for SLObjects with an invalid repository, which happens
 * when SLObjects are created improperly.
 */
extern NSString *SLObjectInvalidRepositoryDescription;

@class SLRepository;

/**
 * A local representative of a single virtual object. The behaviour of this
 * object is defined through a prototype defined on the server, and the identity
 * of this instance is defined through its `creationParameters`.
 */
@interface SLObject : NSObject

/** The SLRepository defining the type of this object. */
@property (readonly, nonatomic, weak) SLRepository *repository;

/**
 * The complete set of parameters to be used to identify/create this object on
 * the server.
 */
@property (readonly, nonatomic, strong) NSDictionary *creationParameters;

/**
 * Returns a new object with the type defined by given repository.
 *
 * @param  repository  The repository this object is associated with.
 * @param  parameters  The creationParameters of the new object.
 * @return             A new object.
 */
+ (instancetype)objectWithRepository:(SLRepository *)repository
                         parameters:(NSDictionary *)parameters;

/**
 * Initializes a new object with the type defined by the given repository.
 *
 * @param  repository  The repository this object is associated with.
 * @param  parameters  The creationParameters of the new object.
 * @return             The new object.
 */
- (instancetype)initWithRepository:(SLRepository *)repository
                       parameters:(NSDictionary *)parameters;

/**
 * Invokes a remotable method exposed within instances of this class on the
 * server.
 *
 * @see SLAdapter::invokeInstanceMethod:constructorParameters:parameters:success:failure:
 *
 * @param name        The method to invoke (without the prototype), e.g.
 *                    `doSomething`.
 * @param parameters  The parameters to invoke with.
 * @param success     An SLSuccessBlock to be executed when the invocation
 *                    succeeds.
 * @param failure     An SLFailureBlock to be executed when the invocation
 *                    fails.
 */
- (void)invokeMethod:(NSString *)name
          parameters:(NSDictionary *)parameters
             success:(SLSuccessBlock)success
             failure:(SLFailureBlock)failure;

@end

/**
 * A local representative of classes ("prototypes" in JavaScript) defined and
 * made remotable on the server.
 */
@interface SLRepository : NSObject

/** The name given to this class on the server. */
@property (readonly, nonatomic, copy) NSString *className;

/**
 * The SLAdapter that should be used for invoking methods, both for static
 * methods on this repository and all methods on all instances of this class.
 */
@property (readwrite, nonatomic) SLAdapter *adapter;

/**
 * Returns a new Repository representing the named remote class.
 *
 * @param  name  The remote class name.
 * @return       A repository.
 */
+ (instancetype)repositoryWithClassName:(NSString *)name;

/**
 * Initializes a new Repository, associating it with the named remote class.
 *
 * @param  name  The remote class name.
 * @return       The repository.
 */
- (instancetype)initWithClassName:(NSString *)name;

/**
 * Returns a new SLObject as a virtual instance of this remote class.
 *
 * @param  parameters  The `creationParameters` of the new SLObject.
 * @return             A new SLObject based on this class.
 */
- (SLObject *)objectWithParameters:(NSDictionary *)parameters;

/**
 * Invokes a remotable method exposed statically within this class on the
 * server.
 *
 * @see SLAdapter::invokeStaticMethod:parameters:success:failure:
 *
 * @param name        The method to invoke (without the class name), e.g.
 *                    `doSomething`.
 * @param parameters  The parameters to invoke with.
 * @param success     An SLSuccessBlock to be executed when the invocation
 *                    succeeds.
 * @param failure     An SLFailureBlock to be executed when the invocation
 *                    fails.
 */
- (void)invokeStaticMethod:(NSString *)name
                parameters:(NSDictionary *)parameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure;

@end
