/**
 * @file LBUser.m
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBUser.h"
#import "LBRESTAdapter.h"
#import "LBAccessToken.h"

@implementation LBUser

@end

@interface LBUserRepository ()

@property (nonatomic, strong) LBAccessTokenRepository *accessTokenRepository;

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

- (LBUser *)createUserWithEmail:(NSString*)email
                       password:(NSString*)password
{
    return [self createUserWithEmail:email password:password dictionary:nil];
}

- (void)loginWithEmail:(NSString*)email
                    password:(NSString*)password
                     success:(LBUserLoginSuccessBlock)success
                     failure:(SLFailureBlock)failure {
    NSParameterAssert(email);
    NSParameterAssert(password);
    [self invokeStaticMethod:@"login"
                  parameters:@{ @"email": email, @"password": password }
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         LBRESTAdapter* adapter = (LBRESTAdapter*)self.adapter;
                         if (self.accessTokenRepository == nil)
                             self.accessTokenRepository = (LBAccessTokenRepository *)[adapter repositoryWithClass:[LBAccessTokenRepository class]];
                         LBAccessToken *accessToken = (LBAccessToken*)[self.accessTokenRepository modelWithDictionary:(NSDictionary*)value];
                         adapter.accessToken = accessToken._id;
                         success(accessToken);
                     } failure:failure];
}

- (void)userByLoginWithEmail:(NSString*)email
                    password:(NSString*)password
                     success:(LBUserLoginFindUserSuccessBlock)success
                     failure:(SLFailureBlock)failure {
    NSParameterAssert(email);
    NSParameterAssert(password);
    [self loginWithEmail:email password:password success:^(LBAccessToken* token){
        [self findById:token.userId success:^(LBModel *model){
            success((LBUser*)model);
        } failure:failure];
    } failure:failure];
}

- (void)logoutWithSuccess:(LBUserLogoutSuccessBlock)success
                  failure:(SLFailureBlock)failure {
    [self invokeStaticMethod:@"logout"
                  parameters:nil
                     success:^(id value) {
                         success();
                     }
                     failure:failure];
}

@end