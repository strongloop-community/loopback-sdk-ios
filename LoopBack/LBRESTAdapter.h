//
//  LBRESTAdapter.h
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/20/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <SLRemoting/SLRemoting.h>

#import "LBModel.h"

@interface LBRESTAdapter : SLRESTAdapter

- (LBModelPrototype *)prototypeWithName:(NSString *)name;
- (LBModelPrototype *)prototypeWithClass:(Class)type;

@end
