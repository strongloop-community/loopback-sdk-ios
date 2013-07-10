//
//  LBRESTAdapter.m
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/20/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "LBRESTAdapter.h"

@interface LBRESTAdapter()

- (void)attachPrototype:(LBModelPrototype *)prototype;

@end

@implementation LBRESTAdapter

- (LBModelPrototype *)prototypeWithName:(NSString *)name {
    NSParameterAssert(name);

    LBModelPrototype *prototype = [LBModelPrototype prototypeWithName:name];
    [self attachPrototype:prototype];
    return prototype;
}

- (LBModelPrototype *)prototypeWithClass:(Class)type {
    NSParameterAssert(type);
    NSParameterAssert([type isSubclassOfClass:[LBModelPrototype class]]);
    NSParameterAssert([type respondsToSelector:@selector(prototype)]);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
    LBModelPrototype *prototype = (LBModelPrototype *)[type prototype];
#pragma clang diagnostic pop

    [self attachPrototype:prototype];
    return prototype;
}

- (void)attachPrototype:(LBModelPrototype *)prototype {
    [self.contract addItemsFromContract:[prototype contract]];
    prototype.adapter = self;
}

@end
