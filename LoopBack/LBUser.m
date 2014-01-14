/**
 * @file LBUser.m
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBUser.h"

@implementation LBUser

- (NSString *)description {
    return [NSString stringWithFormat: @"<LBUser %@>", [self toDictionary]];
}

- (void)logoutWithSuccess:(LBUserLogoutSuccessBlock)success
                  failure:(SLFailureBlock)failure {
    NSString* accessToken = [self objectForKeyedSubscript:@"id"];
    [self.repository invokeStaticMethod:@"logout"
                             parameters:[NSDictionary dictionaryWithObject:accessToken forKey:@"access_token"]
                                success:^(id value) {
                                    success();
                                }
                                failure:failure];
}

@end

@implementation LBUserRepository

+ (instancetype)repository {
    LBUserRepository *repository = [self repositoryWithClassName:@"users"];
    repository.modelClass = [LBUser class];
    return repository;
}

- (SLRESTContract *)contract {
    SLRESTContract *contract = [super contract];
    
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/logout", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.logout", self.className]];
    
    return contract;
}

- (LBUser *)createUserWithEmail:(NSString*)email
                       password:(NSString*)password
                     dictionary:(NSDictionary *)dictionary
{
    LBUser *user = (LBUser *)[self modelWithDictionary:dictionary];
    user.email = email;
    user.password = password;
    return user;
}

- (void)userByLoginWithEmail:(NSString*)email
                    password:(NSString*)password
                     success:(LBUserLoginSuccessBlock)success
                     failure:(SLFailureBlock)failure {
    NSParameterAssert(email);
    NSParameterAssert(password);
    [self invokeStaticMethod:@"login"
                  parameters:@{ @"email": email, @"password": password }
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         LBUser *user = (LBUser *)[self modelWithDictionary:(NSDictionary*)value];
                         user.email = email;
                         user.password = password;
                         success(user);
                     } failure:failure];
}

@end