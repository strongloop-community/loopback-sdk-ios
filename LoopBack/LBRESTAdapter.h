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
 * Returns a new LBModelRepository or LBPersistedModelRepository representing the named model type.
 *
 * @param  name       The model name.
 * @param  persisted  A flag to specify `LBPersistedModelRepository` to be created.
 *                    `NO` to create a `LBModelRepository`.
 * @return            A new repository instance.
 */

- (LBModelRepository *)repositoryWithModelName:(NSString *)name persisted:(BOOL)persisted;

/**
 * Returns a new LBModelRepository from the given subclass.
 *
 * @param  type A subclass of LBModelRepository to use.
 * @return      A new repository instance.
 */
- (LBModelRepository *)repositoryWithClass:(Class)type;

@end
