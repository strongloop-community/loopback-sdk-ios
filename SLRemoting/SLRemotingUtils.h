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
#define ASYNC_TEST_START XCTestExpectation *expectation = [self expectationWithDescription:[NSString stringWithUTF8String:__FUNCTION__]];

/**
 * Marks the end of an asynchronous unit test.
 */
#define ASYNC_TEST_END [self waitForExpectationsWithTimeout:10 handler:nil];

/**
 * Signals the completion of an asynchronous unit test.
 */
#define ASYNC_TEST_SIGNAL [expectation fulfill];

/**
 * Fails an asynchronous unit test, additionally signaling its completion.
 */
#define ASYNC_TEST_FAILURE_BLOCK \
^(NSError *error) { \
    XCTFail(@"Test failed: %@", error.description); \
    [expectation fulfill]; \
}

/**
 * A container for helper methods.
 */
@interface SLRemotingUtils : NSObject

@end
