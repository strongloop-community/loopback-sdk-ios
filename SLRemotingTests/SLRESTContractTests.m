//
//  SLRESTContractTests.m
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/6/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLRESTContractTests.h"

#import "SLRESTAdapter.h"
#import "SLObject.h"

@interface SLRESTContractTests() {
    SLRESTAdapter *adapter;
    SLRESTContract *contract;
    SLRepository *TestClass;
}

@end

@implementation SLRESTContractTests

- (void)setUp {
    [super setUp];
    
    adapter = [SLRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3001"]];
    
    [adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/contract/customizedGetSecret" verb:@"GET"] forMethod:@"contract.getSecret"];
    [adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/contract/customizedTransform" verb:@"GET"] forMethod:@"contract.transform"];
    [adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/ContractClass/:name/getName" verb:@"POST"] forMethod:@"ContractClass.prototype.getName"];
    [adapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/ContractClass/:name/greet" verb:@"POST"] forMethod:@"ContractClass.prototype.greet"];
    
    TestClass = [SLRepository repositoryWithClassName:@"ContractClass"];
    TestClass.adapter = adapter;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAddItemsFromContract {
    SLRESTContract *parent = [SLRESTContract contract];
    SLRESTContract *child = [SLRESTContract contract];

    [parent addItem:[SLRESTContractItem itemWithPattern:@"/wrong/route" verb:@"OOPS"] forMethod:@"test.route"];
    [child addItem:[SLRESTContractItem itemWithPattern:@"/test/route" verb:@"GET"] forMethod:@"test.route"];
    [child addItem:[SLRESTContractItem itemWithPattern:@"/new/route" verb:@"POST"] forMethod:@"new.route"];

    [parent addItemsFromContract:child];
    STAssertTrue([[parent urlForMethod:@"test.route" parameters:@{}] isEqualToString:@"/test/route"], @"Wrong URL.");
    STAssertTrue([[parent verbForMethod:@"test.route"] isEqualToString:@"GET"], @"Wrong verb.");
    STAssertTrue([[parent urlForMethod:@"new.route" parameters:@{}] isEqualToString:@"/new/route"], @"Wrong URL.");
    STAssertTrue([[parent verbForMethod:@"new.route"] isEqualToString:@"POST"], @"Wrong verb.");
}

- (void)testGet {
    ASYNC_TEST_START
    [adapter invokeStaticMethod:@"contract.getSecret"
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
    [adapter invokeStaticMethod:@"contract.transform"
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
    [adapter invokeInstanceMethod:@"ContractClass.prototype.getName"
            constructorParameters:@{ @"name": @"somename" }
                       parameters:nil
                          success:^(id value) {
                              STAssertNotNil(value, @"No value returned.");
                              STAssertTrue([@"somename" isEqualToString:value[@"data"]], [NSString stringWithFormat:@"Incorrect value returned: %@", value]);
                              ASYNC_TEST_SIGNAL
                          }
                          failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testTestClassTransform {
    ASYNC_TEST_START
    [adapter invokeInstanceMethod:@"ContractClass.prototype.greet"
            constructorParameters:@{ @"name": @"somename" }
                       parameters:@{ @"other": @"othername" }
                          success:^(id value) {
                              STAssertNotNil(value, @"No value returned.");
                              STAssertTrue([@"Hi, othername!" isEqualToString:value[@"data"]], [NSString stringWithFormat:@"Incorrect value returned: %@", value]);
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
                              STAssertTrue([@"You" isEqualToString:value[@"data"]], [NSString stringWithFormat:@"Incorrect value returned: %@", value]);
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
                   STAssertTrue([@"somename" isEqualToString:value[@"data"]], [NSString stringWithFormat:@"Incorrect value returned: %@", value]);
                   ASYNC_TEST_SIGNAL
               }
               failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRepositoryTransform {
    ASYNC_TEST_START
    SLObject *test = [TestClass objectWithParameters:@{ @"name": @"somename" }];
    
    [test invokeMethod:@"greet"
            parameters:@{ @"other": @"othername" }
               success:^(id value) {
                   STAssertNotNil(value, @"No value returned.");
                   STAssertTrue([@"Hi, othername!" isEqualToString:value[@"data"]], [NSString stringWithFormat:@"Incorrect value returned: %@", value]);
                   ASYNC_TEST_SIGNAL
               }
               failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
