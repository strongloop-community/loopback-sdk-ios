/**
 * @file LBRESTAdapter.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "LBRESTAdapter.h"

static NSString * const DEFAULTS_ACCESSTOKEN_KEY = @"LBRESTAdapterAccessToken";

@interface LBRESTAdapter()

- (void)attachRepository:(LBModelRepository *)repository;
- (void)saveAccessToken:(NSString *)accessToken;
- (NSString *)loadAccessToken;

@end

@implementation LBRESTAdapter

- (instancetype)initWithURL:(NSURL *)url allowsInvalidSSLCertificate : (BOOL) allowsInvalidSSLCertificate {
    self = [super initWithURL:url allowsInvalidSSLCertificate:allowsInvalidSSLCertificate];

    if (self) {
        self.accessToken = [self loadAccessToken];
    }

    return self;
}

- (void)setAccessToken:(NSString *)accessToken {
    super.accessToken = accessToken;
    [self saveAccessToken:accessToken];
}

- (LBModelRepository *)repositoryWithModelName:(NSString *)name {
    NSParameterAssert(name);

    LBModelRepository *repository = [LBModelRepository repositoryWithClassName:name];
    [self attachRepository:repository];
    return repository;
}

- (LBPersistedModelRepository *)repositoryWithPersistedModelName:(NSString *)name {
    NSParameterAssert(name);

    LBPersistedModelRepository *repository = [LBPersistedModelRepository repositoryWithClassName:name];
    [self attachRepository:repository];
    return repository;
}

// The following method has been deprecated
- (LBModelRepository *)repositoryWithModelName:(NSString *)name persisted:(BOOL)persisted {
    if (persisted) {
        return [self repositoryWithPersistedModelName:name];
    } else {
        return [self repositoryWithModelName:name];
    }
}

- (LBModelRepository *)repositoryWithClass:(Class)type {
    if (type == nil) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Argument cannot be nil"
                                     userInfo:nil];
    }
    if (![type isSubclassOfClass:[LBModelRepository class]]) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Argument needs to be a subclass of LBModelRepository"
                                     userInfo:nil];
    }
    if (![type respondsToSelector:@selector(repository)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:[NSString stringWithFormat:
                                               @"%@ must define 'repository' method", type]
                                     userInfo:nil];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    LBModelRepository *repository = (LBModelRepository *)[type repository];
#pragma clang diagnostic pop

    [self attachRepository:repository];
    return repository;
}

- (void)attachRepository:(LBModelRepository *)repository {
    [self.contract addItemsFromContract:[repository contract]];
    repository.adapter = self;
}

- (void)saveAccessToken:(NSString *)accessToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:DEFAULTS_ACCESSTOKEN_KEY];
}

- (NSString *)loadAccessToken {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *accessToken = [defaults objectForKey:DEFAULTS_ACCESSTOKEN_KEY];
    return accessToken;
}

@end
