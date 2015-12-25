/**
 * @file LBUser.h
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBPersistedModel.h"

@class LBAccessToken;

/**
 * A local representative of a user instance on the server.
 */
@interface LBUser : LBPersistedModel

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
@interface LBUserRepository : LBPersistedModelRepository

@property (nonatomic, readonly) NSString *currentUserId;
@property (nonatomic, readonly) LBUser *cachedCurrentUser;

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
 * LBUserRepository::loginWithEmail:password:success:failure: is successful.
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
 * LBUserRepository::userByLoginWithEmail:password:success:failure: is successful.
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
 * Blocks of this type are executed when
 * LBUserRepository::findCurrentUserWithSuccess:failure: is successful.
 */
typedef void (^LBUserFindUserSuccessBlock)(LBUser *user);
/**
 * Fetch the user model of the currently logged in user.
 * Invokes {@code success(nil)} when no user is logged in.
 *
 * @param success  The block to be executed when the fetch is successful.
 * @param failure  The block to be executed when the fetch fails.
 */
- (void)findCurrentUserWithSuccess:(LBUserFindUserSuccessBlock)success
                           failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when LBUserRepository::logoutWithSuccess:success:failure: is
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

/**
 * Blocks of this type are executed when
 * LBUserRepository::resetPasswordWithEmail:success:failure: is successful.
 */
typedef void (^LBUserResetSuccessBlock)();
/**
 * Triggers reset password for a user with email.
 *
 * @param email    The user email.
 * @param success  The block to be executed when the reset is successful.
 * @param failure  The block to be executed when the reset fails.
 */
- (void)resetPasswordWithEmail:(NSString*)email
               success:(LBUserResetSuccessBlock)success
               failure:(SLFailureBlock)failure;

@end