/**
 * @file LBAccessToken.h
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBPersistedModel.h"

/**
 * An access token returned from the server for access control.
 */
@interface LBAccessToken : LBPersistedModel

/** The user id associated with this access token. */
@property (nonatomic, copy) NSString *userId;

@end

/**
 * A local representative of an access token on the server.
 */
@interface LBAccessTokenRepository : LBPersistedModelRepository

+ (instancetype)repository;

@end