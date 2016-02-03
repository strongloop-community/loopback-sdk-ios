/**
 * @file LBRESTAdapter.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLRemoting.h"

#import "LBModel.h"
#import "LBPersistedModel.h"

/**
 * An extension to the vanilla SLRESTAdapter to make working with LBModels
 * easier.
 */
@interface LBRESTAdapter : SLRESTAdapter

/**
 * Returns a new LBModelRepository representing the named model type.
 *
 * @param  name       The model name.
 * @return            A new repository instance.
 */
- (LBModelRepository *)repositoryWithModelName:(NSString *)name;

/**
 * Returns a new LBPersistedModelRepository representing the named model type.
 *
 * @param  name       The model name.
 * @return            A new repository instance.
 */
- (LBPersistedModelRepository *)repositoryWithPersistedModelName:(NSString *)name;

- (LBModelRepository *)repositoryWithModelName:(NSString *)name persisted:(BOOL)persisted
    __attribute((deprecated("use repositoryWithModelName or repositoryWithPersistedModelName")));

/**
 * Returns a new LBModelRepository from the given subclass.
 *
 * @param  type A subclass of LBModelRepository to use.
 * @return      A new repository instance.
 */
- (LBModelRepository *)repositoryWithClass:(Class)type;

@end
