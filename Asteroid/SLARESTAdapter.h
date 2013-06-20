//
//  SLARESTAdapter.h
//  Asteroid
//
//  Created by Michael Schoonmaker on 6/20/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLRESTAdapter.h"

#import "SLAModel.h"

@interface SLARESTAdapter : SLRESTAdapter

- (SLAModelPrototype *)prototypeWithName:(NSString *)name;
- (SLAModelPrototype *)prototypeWithClass:(Class)type;

@end
