/**
 * @file LBUser.h
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBModel.h"

/**
 * A local representative of a user instance on the server.
 */
@interface LBUser : LBModel

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

/**
 * Blocks of this type are executed when LBUser::logoutWithSuccess: is
 * successful.
 */
typedef void (^LBUserLogoutSuccessBlock)();
/**
 * Logs out the user.
 *
 * @param success  The block to be executed when the logout is successful.
 * @param failure  The block to be executed when the logout fails.
 */
- (void)logoutWithSuccess:(LBUserLogoutSuccessBlock)success
                  failure:(SLFailureBlock)failure;

@end

/**
 * A local representative of a single model type on the server, encapsulating
 * the name of the model type for easy LBUser creation, login, and
 * management.
 */
@interface LBUserRepository : LBModelRepository

+ (instancetype)repository;

/**
 * Creates a user with the given credentials.
 *
 * @param  email       The user email.
 * @param  password    The user password.
 * @param  dictionary  Any additional data to encapsulate.
 */
- (LBUser *)createUserWithEmail:(NSString*)email
                       password:(NSString*)password
                     dictionary:(NSDictionary *)dictionary;

/**
 * Blocks of this type are executed when
 * LBUserRepository::login:success:failure: is successful.
 */
typedef void (^LBUserLoginSuccessBlock)(LBUser *user);
/**
 * Attempts to log in with the given credentials.
 *
 * @param email    The user email.
 * @param password The user password.
 * @param success  The block to be executed when the login is successful.
 * @param failure  The block to be executed when the login fails.
 */
- (void)userByLoginWithEmail:(NSString*)email
                    password:(NSString*)password
                     success:(LBUserLoginSuccessBlock)success
                     failure:(SLFailureBlock)failure;

@end