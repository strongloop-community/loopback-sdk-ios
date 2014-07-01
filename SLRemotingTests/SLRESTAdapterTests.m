//
//  SLRESTAdapterTests.m
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/3/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLRESTAdapterTests.h"

#import "SLRESTAdapter.h"
#import "SLObject.h"

@interface SLRESTAdapterTests() {
    SLRESTAdapter *adapter;
    SLRepository *TestClass;
}

@end

@implementation SLRESTAdapterTests

- (void)setUp {
    [super setUp];
    
    adapter = [SLRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3001"]];
    TestClass = [SLRepository repositoryWithClassName:@"SimpleClass"];
    TestClass.adapter = adapter;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGet {
    ASYNC_TEST_START
    [adapter invokeStaticMethod:@"simple.getSecret"
                     parameters:nil
                        success:^(id value) {
                            STAssertNotNil(value, @"No value returned.");
                            STAssertTrue([@"shhh!" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                            ASYNC_TEST_SIGNAL
                        }
                        failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testTransform {
    ASYNC_TEST_START
    [adapter invokeStaticMethod:@"simple.transform"
                     parameters:@{ @"str": @"somevalue" }
                        success:^(id value) {
                            STAssertNotNil(value, @"No value returned.");
                            STAssertTrue([@"transformed: somevalue" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                            ASYNC_TEST_SIGNAL
                        }
                        failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testTestClassGet {
    ASYNC_TEST_START
    [adapter invokeInstanceMethod:@"SimpleClass.prototype.getName"
            constructorParameters:@{ @"name": @"somename" }
                       parameters:nil
                          success:^(id value) {
                              STAssertNotNil(value, @"No value returned.");
                              STAssertTrue([@"somename" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                              ASYNC_TEST_SIGNAL
                          }
                          failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testTestClassTransform {
    ASYNC_TEST_START
    [adapter invokeInstanceMethod:@"SimpleClass.prototype.greet"
            constructorParameters:@{ @"name": @"somename" }
                       parameters:@{ @"other": @"othername" }
                          success:^(id value) {
                              STAssertNotNil(value, @"No value returned.");
                              STAssertTrue([@"Hi, othername!" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                              ASYNC_TEST_SIGNAL
                          }
                          failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRepositoryStatic {
    ASYNC_TEST_START
    [TestClass invokeStaticMethod:@"getFavoritePerson"
                       parameters:nil
                          success:^(id value) {
                              STAssertNotNil(value, @"No value returned.");
                              STAssertTrue([@"You" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                              ASYNC_TEST_SIGNAL
                          }
                          failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRepositoryGet {
    ASYNC_TEST_START
    SLObject *test = [TestClass objectWithParameters:@{ @"name": @"somename" }];
    
    [test invokeMethod:@"getName"
            parameters:nil
               success:^(id value) {
                   STAssertNotNil(value, @"No value returned.");
                   STAssertTrue([@"somename" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                   ASYNC_TEST_SIGNAL
               }
               failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRepositoryTransform {
    ASYNC_TEST_START
    SLObject *test = [TestClass objectWithParameters:@{ @"name": @{ @"somekey": @"somevalue" }}];
    
    [test invokeMethod:@"greet"
            parameters:@{ @"other": @"othername" }
               success:^(id value) {
                   STAssertNotNil(value, @"No value returned.");
                   STAssertTrue([@"Hi, othername!" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                   ASYNC_TEST_SIGNAL
               }
               failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
