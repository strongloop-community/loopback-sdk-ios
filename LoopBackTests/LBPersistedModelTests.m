//
//  LBPersistedModelTests.m
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LBPersistedModel.h"
#import "LBRESTAdapter.h"
#import "SLRemotingTestsUtils.h"

static NSNumber *lastId;

@interface LBPersistedModelTests : XCTestCase

@property (nonatomic) LBPersistedModelRepository *repository;

@end

@implementation LBPersistedModelTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"TestSuite for LBPersistedModel."];
    [suite addTest:[self testCaseWithSelector:@selector(testCreate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFind)]];
    [suite addTest:[self testCaseWithSelector:@selector(testAll)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFindWithFilter)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFindOne)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFindOneWithFilter)]];
    [suite addTest:[self testCaseWithSelector:@selector(testUpdate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testUpdateRightAfterCreate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testRemove)]];
    return suite;
}


- (void)setUp {
    [super setUp];

    LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = [adapter repositoryWithPersistedModelName:@"widgets"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreate {
    LBPersistedModel *model = (LBPersistedModel*)[self.repository modelWithDictionary: @{
        @"name": @"Foobar",
        @"bars": @1
    }];

    XCTAssertEqualObjects(model[@"name"], @"Foobar", @"Invalid name.");
    XCTAssertEqualObjects(model[@"bars"], @1, @"Invalid bars.");
    XCTAssertNil(model._id, @"Invalid id");

    ASYNC_TEST_START
    [model saveWithSuccess:^{
        NSLog(@"Completed with: %@", model._id);
        XCTAssertNotNil(model._id, @"Invalid id");
        lastId = model._id;
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFind {
    ASYNC_TEST_START
    [self.repository findById:@2 success:^(LBPersistedModel *model) {
        XCTAssertNotNil(model, @"No model found with ID 2");
        XCTAssertTrue([model isMemberOfClass:[LBPersistedModel class]], @"Invalid class.");
        XCTAssertEqualObjects(model[@"name"], @"Bar", @"Invalid name");
        XCTAssertEqualObjects(model[@"bars"], @1, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testAll {
    ASYNC_TEST_START
    [self.repository allWithSuccess:^(NSArray *models) {
        XCTAssertNotNil(models, @"No models returned.");
        XCTAssertTrue([models count] >= 2, @"Invalid # of models returned: %lu", (unsigned long)[models count]);
        XCTAssertTrue([models[0] isMemberOfClass:[LBPersistedModel class]], @"Invalid class.");
        XCTAssertEqualObjects(models[0][@"name"], @"Foo", @"Invalid name");
        XCTAssertEqualObjects(models[0][@"bars"], @0, @"Invalid bars");
        XCTAssertEqualObjects(models[1][@"name"], @"Bar", @"Invalid name");
        XCTAssertEqualObjects(models[1][@"bars"], @1, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFindWithFilter {
    ASYNC_TEST_START
    [self.repository findWithFilter:@{@"where": @{ @"name" : @"Foo" }}
                            success:^(NSArray *models) {
        XCTAssertNotNil(models, @"No models returned.");
        XCTAssertTrue([models count] >= 1, @"Invalid # of models returned: %lu", (unsigned long)[models count]);
        XCTAssertTrue([models[0] isMemberOfClass:[LBPersistedModel class]], @"Invalid class.");
        XCTAssertEqualObjects(models[0][@"name"], @"Foo", @"Invalid name");
        XCTAssertEqualObjects(models[0][@"bars"], @0, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFindOne {
    ASYNC_TEST_START
    [[self.repository adapter] invokeStaticMethod:@"widgets.findOne"
                                       parameters:@{ @"filter": @{@"where": @{ @"name" : @"Foo" }}}
                                   bodyParameters:nil
                                     outputStream:nil
                                          success:^(LBPersistedModel *model) {
        XCTAssertNotNil(model, @"No models returned.");
        XCTAssertEqualObjects(model[@"name"], @"Foo", @"Invalid name");
        XCTAssertEqualObjects(model[@"bars"], @0, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFindOneWithFilter {
    ASYNC_TEST_START
    [self.repository findOneWithFilter: @{@"where": @{ @"name" : @"Foo" }}
                               success:^(LBPersistedModel *model) {
         XCTAssertNotNil(model, @"No models returned.");
         XCTAssertEqualObjects(model[@"name"], @"Foo", @"Invalid name");
         XCTAssertEqualObjects(model[@"bars"], @0, @"Invalid bars");
         ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUpdate {
    LBPersistedModel *model = (LBPersistedModel*)[self.repository modelWithDictionary: @{
        @"name": @"Foobar",
        @"bars": @123
    }];

    ASYNC_TEST_START
    [model saveWithSuccess:^{
        NSNumber *tempId = model._id;
        // find the model just created
        [self.repository findById:tempId success:^(LBPersistedModel *model) {
            XCTAssertNotNil(model, @"No model found");
            // update
            model[@"name"] = @"Barfoo";
            [model saveWithSuccess:^() {
                // find again
                [self.repository findById:tempId success:^(LBPersistedModel *model) {
                    // verify
                    XCTAssertNotNil(model, @"No model found with ID 2");
                    XCTAssertEqualObjects(model[@"name"], @"Barfoo", @"Invalid name");
                    XCTAssertEqualObjects(model[@"bars"], @123, @"Invalid bars");
                    // remove
                    [model destroyWithSuccess:^() {
                        ASYNC_TEST_SIGNAL
                    } failure:ASYNC_TEST_FAILURE_BLOCK];
                } failure:ASYNC_TEST_FAILURE_BLOCK];
            } failure:ASYNC_TEST_FAILURE_BLOCK];
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUpdateRightAfterCreate {
    LBPersistedModel *model = (LBPersistedModel*)[self.repository modelWithDictionary: @{
        @"name": @"Foobar",
        @"bars": @123
    }];

    ASYNC_TEST_START
    // create
    [model saveWithSuccess:^{
        // update
        model[@"name"] = @"Barfoo";
        [model saveWithSuccess:^() {
            // find
            [self.repository findById:model._id success:^(LBPersistedModel *returnedModel) {
                // verify
                XCTAssertNotNil(returnedModel, @"No model found");
                XCTAssertEqualObjects(returnedModel[@"name"], @"Barfoo", @"Invalid name");
                XCTAssertEqualObjects(returnedModel[@"bars"], @123, @"Invalid bars");
                // remove
                [model destroyWithSuccess:^() {
                    ASYNC_TEST_SIGNAL
                } failure:ASYNC_TEST_FAILURE_BLOCK];
            } failure:ASYNC_TEST_FAILURE_BLOCK];
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRemove {
    ASYNC_TEST_START
    [self.repository findById:lastId success:^(LBPersistedModel *model) {
        [model destroyWithSuccess:^{
            [self.repository findById:lastId success:^(LBPersistedModel *model) {
                XCTFail(@"Model found after removal");
            } failure:^(NSError *err) {
                ASYNC_TEST_SIGNAL
            }];
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}


@end
