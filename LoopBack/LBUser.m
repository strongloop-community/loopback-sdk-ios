/**
 * @file LBUser.m
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBUser.h"
#import "LBRESTAdapter.h"
#import "LBAccessToken.h"

static NSString * const DEFAULTS_CURRENT_USER_ID_KEY = @"LBUserRepositoryCurrentUserId";

@implementation LBUser

@end

@interface LBUserRepository () {
    NSString *_currentUserId;
}

@property (nonatomic, strong) LBAccessTokenRepository *accessTokenRepository;
@property (nonatomic, readwrite) NSString *currentUserId;
@property BOOL isCurrentUserIdLoaded;
@property (nonatomic, readwrite) LBUser *cachedCurrentUser;

- (void)loadCurrentUserIdIfNotLoaded;
- (void)saveCurrentUserId;

@end

@implementation LBUserRepository

+ (instancetype)repository {
    LBUserRepository *repository = [self repositoryWithClassName:@"users"];
    return repository;
}

- (SLRESTContract *)contract {
    SLRESTContract *contract = [super contract];

    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/login?include=user", self.className] verb:@"POST"]
            forMethod:[NSString stringWithFormat:@"%@.login", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/logout", self.className] verb:@"POST"]
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
                  parameters:nil
              bodyParameters:@{ @"email": email, @"password": password }
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         LBRESTAdapter* adapter = (LBRESTAdapter*)self.adapter;
                         if (self.accessTokenRepository == nil) {
                             self.accessTokenRepository = (LBAccessTokenRepository *)[adapter repositoryWithClass:[LBAccessTokenRepository class]];
                         }
                         LBAccessToken *accessToken = (LBAccessToken*)[self.accessTokenRepository modelWithDictionary:(NSDictionary*)value];
                         adapter.accessToken = accessToken._id;
                         self.currentUserId = accessToken.userId;
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
            self.cachedCurrentUser = (LBUser*)model;
            success((LBUser*)model);
        } failure:failure];
    } failure:failure];
}

- (void)findCurrentUserWithSuccess:(LBUserFindUserSuccessBlock)success
                           failure:(SLFailureBlock)failure {
    if (self.currentUserId == nil) {
        success(nil);
        return;
    }

    [self findById:self.currentUserId success:^(LBModel *model) {
        self.cachedCurrentUser = (LBUser*)model;
        success((LBUser*)model);
    } failure:failure];
}

- (void)logoutWithSuccess:(LBUserLogoutSuccessBlock)success
                  failure:(SLFailureBlock)failure {
    [self invokeStaticMethod:@"logout"
                  parameters:nil
                     success:^(id value) {
                         LBRESTAdapter* adapter = (LBRESTAdapter*)self.adapter;
                         adapter.accessToken = nil;
                         self.currentUserId = nil;
                         success();
                     }
                     failure:failure];
}

- (void)resetPasswordWithEmail:(NSString*)email
                       success:(LBUserResetSuccessBlock)success
                       failure:(SLFailureBlock)failure {
    NSParameterAssert(email);
    [self invokeStaticMethod:@"reset"
                  parameters:nil
              bodyParameters:@{ @"email": email }
                     success:^(id value) {
                         success();
                     }
                     failure:failure];
}

- (NSString *)currentUserId {
    [self loadCurrentUserIdIfNotLoaded];
    return _currentUserId;
}

- (void)setCurrentUserId:(NSString *)currentUserId {
    _currentUserId = currentUserId;
    self.cachedCurrentUser = nil;
    [self saveCurrentUserId];
}

- (void)loadCurrentUserIdIfNotLoaded {
    if (self.isCurrentUserIdLoaded) {
        return;
    }
    self.isCurrentUserIdLoaded = YES;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _currentUserId = [defaults objectForKey:DEFAULTS_CURRENT_USER_ID_KEY];
}

- (void)saveCurrentUserId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_currentUserId forKey:DEFAULTS_CURRENT_USER_ID_KEY];
}

@end