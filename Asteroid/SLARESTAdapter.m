//
//  SLARESTAdapter.m
//  Asteroid
//
//  Created by Michael Schoonmaker on 6/20/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLARESTAdapter.h"

@interface SLARESTAdapter()

- (void)attachPrototype:(SLAModelPrototype *)prototype;

@end

@implementation SLARESTAdapter

- (SLAModelPrototype *)prototypeWithName:(NSString *)name {
    NSParameterAssert(name);

    SLAModelPrototype *prototype = [SLAModelPrototype prototypeWithName:name];
    [self attachPrototype:prototype];
    return prototype;
}

- (SLAModelPrototype *)prototypeWithClass:(Class)type {
    NSParameterAssert(type);
    NSParameterAssert([type isSubclassOfClass:[SLAModelPrototype class]]);
    NSParameterAssert([type respondsToSelector:@selector(prototype)]);

    SLAModelPrototype *prototype = (SLAModelPrototype *)[type prototype];
    [self attachPrototype:prototype];
    return prototype;
}

- (void)attachPrototype:(SLAModelPrototype *)prototype {
    [self.contract addItemsFromContract:[prototype contract]];
    prototype.adapter = self;
}

@end
