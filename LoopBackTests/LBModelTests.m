//
//  LBModelTests.m
//  LoopBack
//
//  Copyright (c) 2015 StrongLoop. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LBModel.h"
#import "LBRESTAdapter.h"

@interface LBModelTests : XCTestCase

@property (nonatomic) LBModelRepository *repository;

@end

@implementation LBModelTests

- (void)setUp {
    [super setUp];

    LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = [adapter repositoryWithModelName:@"widgets"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testObjectForKeyedSubscript {
    LBModel *model = [self.repository modelWithDictionary:@{ @"name": @"Foo", @"bars": @123 }];

    XCTAssertEqualObjects(@"Foo", [model objectForKeyedSubscript:@"name"], @"Invalid name.");
    XCTAssertEqualObjects(@123, [model objectForKeyedSubscript:@"bars"], @"Invalid bars.");

    // objectForKeyedSubscript: method enables the use of [key] notation to get the value
    XCTAssertEqualObjects(@"Foo", model[@"name"], @"Invalid name.");
    XCTAssertEqualObjects(@123, model[@"bars"], @"Invalid bars.");
}

- (void)testSetObject {
    LBModel *model = [self.repository model];

    [model setObject:@"Bar" forKeyedSubscript:@"name"];
    [model setObject:@456 forKeyedSubscript:@"bars"];

    XCTAssertEqualObjects(@"Bar", model[@"name"], @"Invalid name.");
    XCTAssertEqualObjects(@456, model[@"bars"], @"Invalid bars.");

    // setObject:forKeyedSubscript: method enables the use of [key] notation to set a value
    model[@"name"] = @"Baz";
    model[@"bars"] = @789;

    XCTAssertEqualObjects(@"Baz", model[@"name"], @"Invalid name.");
    XCTAssertEqualObjects(@789, model[@"bars"], @"Invalid bars.");
}

- (void)testToDictionary {
    NSDictionary *origDict = @{ @"name": @"Foo", @"bars": @123 };
    LBModel *model = [self.repository modelWithDictionary:origDict];

    NSDictionary *dict = [model toDictionary];

    XCTAssertTrue([dict isEqual:origDict], @"Invalid dictionary");
}

@end
