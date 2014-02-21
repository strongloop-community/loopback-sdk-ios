/**
 * @file LBAccessToken.m
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBAccessToken.h"

@implementation LBAccessToken

@end

@implementation LBAccessTokenRepository

+ (instancetype)repository {
    LBAccessTokenRepository *repository = [self repositoryWithClassName:@"accessToken"];
    repository.modelClass = [LBAccessToken class];
    return repository;
}

@end