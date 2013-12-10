//
//  LBModelSubclassingTests.m
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "LBModelSubclassingTests.h"

#import "LBModel.h"
#import "LBRESTAdapter.h"

static NSNumber *lastId;

@interface Widget : LBModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *bars;

@end

@implementation Widget

@end

@interface WidgetRepository : LBModelRepository
+ (instancetype)repository;

@end

@implementation WidgetRepository

+ (instancetype)repository {
    return [self repositoryWithClassName:@"widgets"];
}

@end

@interface LBModelSubclassingTests()

@property (nonatomic) WidgetRepository *repository;

@end

@implementation LBModelSubclassingTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    SenTestSuite *suite = [SenTestSuite testSuiteWithName:@"TestSuite for LBDevice."];
    [suite addTest:[self testCaseWithSelector:@selector(testCreate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFind)]];
    [suite addTest:[self testCaseWithSelector:@selector(testAll)]];
    [suite addTest:[self testCaseWithSelector:@selector(testUpdate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testRemove)]];
    return suite;
}

- (void)setUp {
    [super setUp];

    LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = (WidgetRepository *)[adapter repositoryWithClass:[WidgetRepository class]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreate {
    Widget *model = (Widget*)[self.repository modelWithDictionary:@{ @"name": @"Foobar", @"bars": @1 }];

    STAssertEqualObjects(model.name, @"Foobar", @"Invalid name.");
    STAssertEqualObjects(model.bars, @1, @"Invalid bars.");
    STAssertNil(model._id, nil, @"Invalid id");

    ASYNC_TEST_START
    [model saveWithSuccess:^{
        lastId = model._id;
        STAssertNotNil(model._id, @"Invalid id");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFind {
    ASYNC_TEST_START
    [self.repository findById:@2
                       success:^(LBModel *model) {
                           STAssertNotNil(model, @"No model found with ID 2");
                           STAssertTrue([[model class] isSubclassOfClass:[Widget class]], @"Invalid class.");
                           STAssertEqualObjects(((Widget *)model).name, @"Bar", @"Invalid name");
                           STAssertEqualObjects(((Widget *)model).bars, @1, @"Invalid bars");
                           ASYNC_TEST_SIGNAL
                       } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testAll {
    ASYNC_TEST_START
    [self.repository allWithSuccess:^(NSArray *models) {
        STAssertNotNil(models, @"No models returned.");
        STAssertTrue([models count] >= 2, [NSString stringWithFormat:@"Invalid # of models returned: %lu", (unsigned long)[models count]]);
        STAssertTrue([[models[0] class] isSubclassOfClass:[Widget class]], @"Invalid class.");
        STAssertEqualObjects(((Widget *)models[0]).name, @"Foo", @"Invalid name.");
        STAssertEqualObjects(((Widget *)models[0]).bars, @0, @"Invalid bars");
        STAssertEqualObjects(((Widget *)models[1]).name, @"Bar", @"Invalid name");
        STAssertEqualObjects(((Widget *)models[1]).bars, @1, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUpdate {
    ASYNC_TEST_START
    LBModelFindSuccessBlock verify = ^(LBModel *model) {
        STAssertNotNil(model, @"No model found with ID 2");
        STAssertTrue([[model class] isSubclassOfClass:[Widget class]], @"Invalid class.");
        STAssertEqualObjects(((Widget *)model).name, @"Barfoo", @"Invalid name");
        STAssertEqualObjects(((Widget *)model).bars, @1, @"Invalid bars");

        ((Widget *)model).name = @"Bar";
        [model saveWithSuccess:^{
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
        ASYNC_TEST_SIGNAL
    };

    LBModelSaveSuccessBlock findAgain = ^() {
        [self.repository findById:@2 success:verify failure:ASYNC_TEST_FAILURE_BLOCK];
    };

    LBModelFindSuccessBlock update = ^(LBModel *model) {
        STAssertNotNil(model, @"No model found with ID 2");
        ((Widget *)model).name = @"Barfoo";
        [model saveWithSuccess:findAgain failure:ASYNC_TEST_FAILURE_BLOCK];
    };

    [self.repository findById:@2 success:update failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRemove {
    ASYNC_TEST_START
    [self.repository findById:lastId
                      success:^(LBModel *model) {
                          [model destroyWithSuccess:^{
                              ASYNC_TEST_SIGNAL
                          } failure:ASYNC_TEST_FAILURE_BLOCK];
                      } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}


@end
