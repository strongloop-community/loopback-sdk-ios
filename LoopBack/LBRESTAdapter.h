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
 * Returns a new LBModelPrototype representing the named model type.
 *
 * @param  name The model name.
 * @return      A new prototype instance.
 */
- (LBModelPrototype *)prototypeWithName:(NSString *)name;

/**
 * Returns a new LBModelPrototype from the given subclass.
 *
 * @param  type A subclass of LBModelPrototype to use.
 * @return      A new prototype instance.
 */
- (LBModelPrototype *)prototypeWithClass:(Class)type;

@end
