//
//  SLRemotingUtils.h
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/3/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Helpful macros
//
#define SINGLETON_INTERFACE(name, accessor) + (name *)accessor;
#define SINGLETON_IMPLEMENTATION(name, accessor) \
static name *accessor##Instance = NULL; \
+ (instancetype)accessor \
{ \
    if (!accessor##Instance) { \
        accessor##Instance = [[name alloc] init]; \
    } \
    return accessor##Instance; \
}

#define ASYNC_TEST_START dispatch_semaphore_t sen_semaphore = dispatch_semaphore_create(0);
#define ASYNC_TEST_END \
while (dispatch_semaphore_wait(sen_semaphore, DISPATCH_TIME_NOW)) \
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
#define ASYNC_TEST_SIGNAL dispatch_semaphore_signal(sen_semaphore);
#define ASYNC_TEST_FAILURE_BLOCK \
^(NSError *error) { \
    STFail(error.description); \
    ASYNC_TEST_SIGNAL \
}

//
// Helpful methods
//
@interface SLRemotingUtils : NSObject

@end
