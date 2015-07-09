//
//  LBRESTAdapterTests.m
//  LoopBack
//
//  Copyright (c) 2015 StrongLoop. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LBRESTAdapter.h"

static NSString * const SERVER_URL = @"http://localhost:3001";

@interface LBRESTAdapterTests : XCTestCase

@property (nonatomic, strong) LBRESTAdapter *adapter;

@end

@implementation LBRESTAdapterTests

- (void)setUp {
    [super setUp];
    self.adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:SERVER_URL]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAccessTokenIsStoredInSharedPreferences {
    self.adapter.accessToken = @"an-access-token";

    LBRESTAdapter *anotherAdapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:SERVER_URL]];
    XCTAssertEqualObjects(anotherAdapter.accessToken, @"an-access-token", @"Invalid access token");

    self.adapter.accessToken = @"a-different-access-token";

    LBRESTAdapter *yetAnotherAdapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:SERVER_URL]];
    XCTAssertEqualObjects(yetAnotherAdapter.accessToken, @"a-different-access-token", @"Invalid access token");

    self.adapter.accessToken = nil;
}

@end
