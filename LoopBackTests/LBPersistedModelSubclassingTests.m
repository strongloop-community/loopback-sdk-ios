//
//  LBPersistedModelSubclassingTest.m
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

@interface Widget : LBPersistedModel

@property (nonatomic, copy) NSString *name;
// a Number property can be accessed via either of NSNumber or the primitive type NSInteger.
@property (nonatomic) NSNumber *bars;
@property NSInteger bars2;
// a Boolean property can be accessed via either of NSNumber or the primitive type BOOL.
@property (nonatomic) NSNumber *flag;
@property BOOL flag2;
@property (nonatomic) NSDate *date;

@end

@implementation Widget

@end

@interface WidgetRepository : LBPersistedModelRepository

@end

@implementation WidgetRepository

+ (instancetype)repository {
    return [self repositoryWithClassName:@"widgets"];
}

@end

@interface TestRepository : LBPersistedModelRepository

@end

@implementation TestRepository

@end


@interface LBPersistedModelSubclassingTests : XCTestCase

@property (nonatomic) LBRESTAdapter *adapter;
@property (nonatomic) WidgetRepository *repository;

@end

@implementation LBPersistedModelSubclassingTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"TestSuite for LBPersistedModel subclasses."];
    [suite addTest:[self testCaseWithSelector:@selector(testRepositoryNotOverridden)]];
    [suite addTest:[self testCaseWithSelector:@selector(testCreate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFind)]];
    [suite addTest:[self testCaseWithSelector:@selector(testAll)]];
    [suite addTest:[self testCaseWithSelector:@selector(testUpdate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testRemove)]];
    return suite;
}

- (void)setUp {
    [super setUp];

    self.adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = (WidgetRepository *)[self.adapter repositoryWithClass:[WidgetRepository class]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRepositoryNotOverridden {
    XCTAssertThrows([self.adapter repositoryWithClass:[TestRepository class]],
        @"Exception should be thrown as 'repository' is not overridden.");
}

- (void)testCreate {
    Widget *model = (Widget*)[self.repository modelWithDictionary:@{
        @"name" : @"Foobar",
        @"bars" : @123,
        @"bars2": @123,
        @"flag" : @YES,
        @"flag2": @YES,
        @"date" : @"1970-01-01T00:00:00.000Z"
    }];

    XCTAssertNil(model._id, @"Invalid id");
    XCTAssertEqualObjects(model.name, @"Foobar", @"Invalid name.");
    XCTAssertEqualObjects(model.bars, @123, @"Invalid bars.");
    XCTAssertEqual(model.bars2, 123, @"Invalid bars2.");
    XCTAssertEqualObjects(model.flag, @YES, @"Invalid flag.");
    XCTAssertEqual(model.flag2, YES, @"Invalid flag2.");
    XCTAssertEqualObjects(model.date, [NSDate dateWithTimeIntervalSince1970:0], @"Invalid date.");

    model.bars = @456;
    model.bars2 = 456;
    model.flag = @NO;
    model.flag2 = NO;
    model.date = [NSDate dateWithTimeIntervalSince1970:123];

    ASYNC_TEST_START
    [model saveWithSuccess:^{
        lastId = model._id;
        XCTAssertNotNil(model._id, @"Invalid id");
        XCTAssertEqualObjects(model.bars, @456, @"Invalid bars.");
        XCTAssertEqual(model.bars2, 456, @"Invalid bars2.");
        XCTAssertEqualObjects(model.flag, @NO, @"Invalid flag.");
        XCTAssertEqual(model.flag2, NO, @"Invalid flag2.");
        XCTAssertEqualObjects(model.date, [NSDate dateWithTimeIntervalSince1970:123], @"Invalid date.");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFind {
    ASYNC_TEST_START
    [self.repository findById:@2
                       success:^(LBPersistedModel *model) {
                           XCTAssertNotNil(model, @"No model found with ID 2");
                           XCTAssertTrue([[model class] isSubclassOfClass:[Widget class]], @"Invalid class.");
                           XCTAssertEqualObjects(((Widget *)model).name, @"Bar", @"Invalid name");
                           XCTAssertEqualObjects(((Widget *)model).bars, @1, @"Invalid bars");
                           ASYNC_TEST_SIGNAL
                       } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testAll {
    ASYNC_TEST_START
    [self.repository allWithSuccess:^(NSArray *models) {
        XCTAssertNotNil(models, @"No models returned.");
        XCTAssertTrue([models count] >= 2, @"Invalid # of models returned: %lu", (unsigned long)[models count]);
        XCTAssertTrue([[models[0] class] isSubclassOfClass:[Widget class]], @"Invalid class.");
        XCTAssertTrue([[models[1] class] isSubclassOfClass:[Widget class]], @"Invalid class.");
        XCTAssertEqualObjects(((Widget *)models[0]).name, @"Foo", @"Invalid name.");
        XCTAssertEqualObjects(((Widget *)models[0]).bars, @0, @"Invalid bars");
        XCTAssertEqualObjects(((Widget *)models[1]).name, @"Bar", @"Invalid name");
        XCTAssertEqualObjects(((Widget *)models[1]).bars, @1, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUpdate {
    __block NSString *savedName;
    __block NSDate *savedDate;

    ASYNC_TEST_START
    LBPersistedModelFindSuccessBlock verify = ^(LBPersistedModel *model) {
        XCTAssertNotNil(model, @"No model found with ID 2");
        XCTAssertTrue([[model class] isSubclassOfClass:[Widget class]], @"Invalid class.");
        Widget *widget = (Widget *)model;
        XCTAssertEqualObjects(widget.name, @"Barfoo", @"Invalid name");
        XCTAssertEqualObjects(widget.bars, @1, @"Invalid bars");
        XCTAssertEqualObjects(widget.date, [NSDate dateWithTimeIntervalSince1970:0], @"Invalid date");

        widget.name = savedName;
        widget.date = savedDate;
        [model saveWithSuccess:^{
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    };

    LBPersistedModelSaveSuccessBlock findAgain = ^() {
        [self.repository findById:@2 success:verify failure:ASYNC_TEST_FAILURE_BLOCK];
    };

    LBPersistedModelFindSuccessBlock update = ^(LBPersistedModel *model) {
        XCTAssertNotNil(model, @"No model found with ID 2");
        XCTAssertTrue([[model class] isSubclassOfClass:[Widget class]], @"Invalid class.");
        Widget *widget = (Widget *)model;
        savedName = widget.name;
        savedDate = widget.date;
        widget.name = @"Barfoo";
        widget.date = [NSDate dateWithTimeIntervalSince1970:0];
        [model saveWithSuccess:findAgain failure:ASYNC_TEST_FAILURE_BLOCK];
    };

    [self.repository findById:@2 success:update failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRemove {
    ASYNC_TEST_START
    [self.repository findById:lastId
                      success:^(LBPersistedModel *model) {
                          [model destroyWithSuccess:^{
                              ASYNC_TEST_SIGNAL
                          } failure:ASYNC_TEST_FAILURE_BLOCK];
                      } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}


@end
