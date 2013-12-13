/**
 * @file LBRESTAdapter.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import <LoopBack/SLRemoting.h>

#import "LBModel.h"

/**
 * An extension to the vanilla SLRESTAdapter to make working with LBModels
 * easier.
 */
@interface LBRESTAdapter : SLRESTAdapter

/**
 * Returns a new LBModelRepository representing the named model type.
 *
 * @param  name The model name.
 * @return      A new repository instance.
 */
- (LBModelRepository *)repositoryWithModelName:(NSString *)name;

/**
 * Returns a new LBModelRepository from the given subclass.
 *
 * @param  type A subclass of LBModelRepository to use.
 * @return      A new repository instance.
 */
- (LBModelRepository *)repositoryWithClass:(Class)type;

@end
