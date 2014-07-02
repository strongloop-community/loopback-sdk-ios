/**
 * @file SLRemotingUtils.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * Marks the start of an asynchronous unit test.
 */
#define ASYNC_TEST_START dispatch_semaphore_t sen_semaphore = dispatch_semaphore_create(0);

/**
 * Marks the end of an asynchronous unit test.
 */
#define ASYNC_TEST_END \
while (dispatch_semaphore_wait(sen_semaphore, DISPATCH_TIME_NOW)) \
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];

/**
 * Signals the completion of an asynchronous unit test.
 */
#define ASYNC_TEST_SIGNAL dispatch_semaphore_signal(sen_semaphore);

/**
 * Fails an asynchronous unit test, additionally signaling its completion.
 */
#define ASYNC_TEST_FAILURE_BLOCK \
^(NSError *error) { \
    STFail(error.description); \
    ASYNC_TEST_SIGNAL \
}

/**
 * A container for helper methods.
 */
@interface SLRemotingUtils : NSObject

@end
