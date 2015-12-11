/**
 * @file SLRemotingTestsUtils.h
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * Marks the start of an asynchronous unit test.
 */
// NOTE: since the CI uses Xcode 5, we cannot depend on XCTestExpectation.
// Use dispatch_semaphore instead.
//
// #define ASYNC_TEST_START XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithUTF8String:__FUNCTION__]];
#define ASYNC_TEST_START dispatch_semaphore_t sen_semaphore = dispatch_semaphore_create(0);

/**
 * Marks the end of an asynchronous unit test.
 */
// #define ASYNC_TEST_END [self waitForExpectationsWithTimeout:10 handler:nil];
#define ASYNC_TEST_END \
    while (dispatch_semaphore_wait(sen_semaphore, DISPATCH_TIME_NOW)) \
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];

/**
 * Signals the completion of an asynchronous unit test.
 */
// #define ASYNC_TEST_SIGNAL [expectation fulfill];
#define ASYNC_TEST_SIGNAL dispatch_semaphore_signal(sen_semaphore);

/**
 * Fails an asynchronous unit test, additionally signaling its completion.
 */
// #define ASYNC_TEST_FAILURE_BLOCK \
//     ^(NSError *error) { \
//         XCTFail(@"Test failed: %@", error.description); \
//         [expectation fulfill]; \
//     }
#define ASYNC_TEST_FAILURE_BLOCK \
    ^(NSError *error) { \
        XCTFail(@"Test failed: %@", error.description); \
        ASYNC_TEST_SIGNAL \
    }
