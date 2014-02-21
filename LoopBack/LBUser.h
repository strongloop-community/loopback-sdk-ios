/**
 * @file LBUser.h
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBModel.h"

@class LBAccessToken;

/**
 * A local representative of a user instance on the server.
 */
@interface LBUser : LBModel

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

@property (nonatomic, copy) NSString *realm;
@property (nonatomic, strong) NSNumber *emailVerified;
@property (nonatomic, copy) NSString *status;

@end

/**
 * A local representative of the User type on the server, encapsulating
 * all User properties.
 */
@interface LBUserRepository : LBModelRepository

+ (instancetype)repository;

/**
 * Creates a user with the given credentials and additional data.
 *
 * @param  email       The user email.
 * @param  password    The user password.
 * @param  dictionary  Any additional data to encapsulate.
 */
- (LBUser *)createUserWithEmail:(NSString*)email
                       password:(NSString*)password
                     dictionary:(NSDictionary *)dictionary;

/**
 * Creates a user with the given credentials.
 *
 * @param  email       The user email.
 * @param  password    The user password.
 */
- (LBUser *)createUserWithEmail:(NSString*)email
                       password:(NSString*)password;

/**
 * Blocks of this type are executed when
 * LBUserRepository::login:success:failure: is successful.
 */
typedef void (^LBUserLoginSuccessBlock)(LBAccessToken* token);
/**
 * Attempts to log in with the given credentials.  The returned access
 * token will be passed for all subsequent server interaction. 
 *
 * @param email    The user email.
 * @param password The user password.
 * @param success  The block to be executed when the login is successful.
 * @param failure  The block to be executed when the login fails.
 */
- (void)loginWithEmail:(NSString*)email
              password:(NSString*)password
               success:(LBUserLoginSuccessBlock)success
               failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBUserRepository::login:success:failure: is successful.
 */
typedef void (^LBUserLoginFindUserSuccessBlock)(LBUser *user);
/**
 * Attempts to log in with the given credentials and return the LBUser.
 *
 * @param email    The user email.
 * @param password The user password.
 * @param success  The block to be executed when the login is successful.
 * @param failure  The block to be executed when the login fails.
 */
- (void)userByLoginWithEmail:(NSString*)email
                    password:(NSString*)password
                     success:(LBUserLoginFindUserSuccessBlock)success
                     failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when LBUserRepository::logoutWithSuccess: is
 * successful.
 */
typedef void (^LBUserLogoutSuccessBlock)();
/**
 * Clears the current access token for this session.
 *
 * @param success  The block to be executed when the logout is successful.
 * @param failure  The block to be executed when the logout fails.
 */
- (void)logoutWithSuccess:(LBUserLogoutSuccessBlock)success
                  failure:(SLFailureBlock)failure;
@end