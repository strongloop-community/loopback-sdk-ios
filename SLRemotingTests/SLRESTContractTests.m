//
//  SLRESTContractTests.m
//  SLRemoting
//
//  Created by Michael Schoonmaker on 6/6/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "SLRESTAdapter.h"
#import "SLObject.h"
#import "SLRemotingTestsUtils.h"

static NSString * const SERVER_URL = @"http://localhost:3001";

@interface SLRESTContractTests : XCTestCase {
    SLRESTAdapter *adapter;
    SLRepository *TestClass;
}

@end

@implementation SLRESTContractTests

- (void)setUp {
    [super setUp];
    
    adapter = [SLRESTAdapter adapterWithURL:[NSURL URLWithString:SERVER_URL]];
    
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

- (void)testUrlWithPattern {
    SLRESTContract *contract = [SLRESTContract contract];
    NSMutableDictionary *parameters = [@{ @"id": @"57", @"price": @"42.00" } mutableCopy];

    NSString *url = [contract urlWithPattern:@"/widgets/:id" parameters:parameters];

    XCTAssertEqualObjects(url, @"/widgets/57", @"Invalid URL");
    XCTAssertEqualObjects(parameters, [@{ @"price": @"42.00" } mutableCopy], @"Invalid parameters");
}

- (void)testAddItemsFromContract {
    SLRESTContract *parent = [SLRESTContract contract];
    SLRESTContract *child = [SLRESTContract contract];

    [parent addItem:[SLRESTContractItem itemWithPattern:@"/wrong/route" verb:@"OOPS"] forMethod:@"test.route"];
    [child addItem:[SLRESTContractItem itemWithPattern:@"/test/route" verb:@"GET"] forMethod:@"test.route"];
    [child addItem:[SLRESTContractItem itemWithPattern:@"/new/route" verb:@"POST"] forMethod:@"new.route"];

    [parent addItemsFromContract:child];
    XCTAssertTrue([[parent urlForMethod:@"test.route" parameters:nil] isEqualToString:@"/test/route"], @"Wrong URL.");
    XCTAssertTrue([[parent verbForMethod:@"test.route"] isEqualToString:@"GET"], @"Wrong verb.");
    XCTAssertTrue([[parent urlForMethod:@"new.route" parameters:nil] isEqualToString:@"/new/route"], @"Wrong URL.");
    XCTAssertTrue([[parent verbForMethod:@"new.route"] isEqualToString:@"POST"], @"Wrong verb.");
}

- (void)testGet {
    ASYNC_TEST_START
    [adapter invokeStaticMethod:@"contract.getSecret"
                     parameters:nil
                 bodyParameters:nil
                   outputStream:nil
                        success:^(id value) {
                            XCTAssertNotNil(value, @"No value returned.");
                            XCTAssertTrue([@"shhh!" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                            ASYNC_TEST_SIGNAL
                        }
                        failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testTransform {
    ASYNC_TEST_START
    [adapter invokeStaticMethod:@"contract.transform"
                     parameters:@{ @"str": @"somevalue" }
                 bodyParameters:nil
                   outputStream:nil
                        success:^(id value) {
                            XCTAssertNotNil(value, @"No value returned.");
                            XCTAssertTrue([@"transformed: somevalue" isEqualToString:value[@"data"]], @"Incorrect value returned.");
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
                   bodyParameters:nil
                     outputStream:nil
                          success:^(id value) {
                              XCTAssertNotNil(value, @"No value returned.");
                              XCTAssertTrue([@"somename" isEqualToString:value[@"data"]], @"Incorrect value returned: %@", value);
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
                   bodyParameters:nil
                     outputStream:nil
                          success:^(id value) {
                              XCTAssertNotNil(value, @"No value returned.");
                              XCTAssertTrue([@"Hi, othername!" isEqualToString:value[@"data"]], @"Incorrect value returned: %@", value);
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
                              XCTAssertNotNil(value, @"No value returned.");
                              XCTAssertTrue([@"You" isEqualToString:value[@"data"]], @"Incorrect value returned: %@", value);
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
                   XCTAssertNotNil(value, @"No value returned.");
                   XCTAssertTrue([@"somename" isEqualToString:value[@"data"]], @"Incorrect value returned: %@", value);
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
                   XCTAssertNotNil(value, @"No value returned.");
                   XCTAssertTrue([@"Hi, othername!" isEqualToString:value[@"data"]], @"Incorrect value returned: %@", value);
                   ASYNC_TEST_SIGNAL
               }
               failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testCustomRequestHeader {
    ASYNC_TEST_START
    SLRESTAdapter *customAdapter = [SLRESTAdapter adapterWithURL:[NSURL URLWithString:SERVER_URL]];
    customAdapter.accessToken = @"auth-token";

    [customAdapter.contract addItem:[SLRESTContractItem itemWithPattern:@"/contract/get-auth" verb:@"GET"] forMethod:@"contract.getAuthorizationHeader"];

    [customAdapter invokeStaticMethod:@"contract.getAuthorizationHeader"
                           parameters:nil
                       bodyParameters:nil
                         outputStream:nil
                              success:^(id value) {
                                  XCTAssertNotNil(value, @"No value returned.");
                                  XCTAssertTrue([@"auth-token" isEqualToString:value[@"data"]], @"Incorrect value returned.");
                                  ASYNC_TEST_SIGNAL
                              }
                              failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
