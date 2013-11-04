/**
 * @file LBRESTAdapter.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "LBRESTAdapter.h"

@interface LBRESTAdapter()

- (void)attachRepository:(LBModelRepository *)repository;

@end

@implementation LBRESTAdapter

- (LBModelRepository *)repositoryForClassName:(NSString *)name {
    NSParameterAssert(name);

    LBModelRepository *repository = [LBModelRepository repositoryForClassName:name];
    [self attachRepository:repository];
    return repository;
}

- (LBModelRepository *)repositoryWithClass:(Class)type {
    NSParameterAssert(type);
    NSParameterAssert([type isSubclassOfClass:[LBModelRepository class]]);
    NSParameterAssert([type respondsToSelector:@selector(repository)]);

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

@end
