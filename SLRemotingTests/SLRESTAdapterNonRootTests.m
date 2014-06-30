//
//  SLRESTAdapterTests.m
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/3/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLRESTAdapterNonRootTests.h"

#import "SLRESTAdapter.h"
#import "SLObject.h"

@interface SLRESTAdapterNonRootTests() {
    SLRESTAdapter *adapter;
}

@end

@implementation SLRESTAdapterNonRootTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetMsg {
    ASYNC_TEST_START
    
    adapter = [SLRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3001/nonroot/api"]];
    [adapter invokeStaticMethod:@"getMsg"
                     parameters:nil
                        success:^(id value) {
                            STAssertNotNil(value, @"No value returned.");
                            STAssertTrue([@"Hello" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                            ASYNC_TEST_SIGNAL
                        }
                        failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testConvertMsg {
    ASYNC_TEST_START
    
    adapter = [SLRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3001/nonroot/api"]];
    [adapter invokeStaticMethod:@"convertMsg"
                     parameters:@{ @"str": @"somevalue" }
                        success:^(id value) {
                            STAssertNotNil(value, @"No value returned.");
                            STAssertTrue([@"CONVERTED: SOMEVALUE" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                            ASYNC_TEST_SIGNAL
                        }
                        failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testGetMsgWithTrailingSlash {
    ASYNC_TEST_START
    
    adapter = [SLRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3001/nonroot/api/"]];
    [adapter invokeStaticMethod:@"getMsg"
                     parameters:nil
                        success:^(id value) {
                            STAssertNotNil(value, @"No value returned.");
                            STAssertTrue([@"Hello" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                            ASYNC_TEST_SIGNAL
                        }
                        failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testConvertMsgWithTrailingSlash {
    ASYNC_TEST_START
    
    adapter = [SLRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3001/nonroot/api/"]];
    [adapter invokeStaticMethod:@"convertMsg"
                     parameters:@{ @"str": @"somevalue" }
                        success:^(id value) {
                            STAssertNotNil(value, @"No value returned.");
                            STAssertTrue([@"CONVERTED: SOMEVALUE" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                            ASYNC_TEST_SIGNAL
                        }
                        failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
