//
//  LBModelTests.m
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "LBModelTests.h"

#import "LBModel.h"
#import "LBRESTAdapter.h"

static NSNumber *lastId;

@interface LBModelTests()

@property (nonatomic) LBModelPrototype *prototype;

@end

@implementation LBModelTests

- (void)setUp {
    [super setUp];

    LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.prototype = [adapter prototypeWithName:@"widgets"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreate {
    LBModel __block *model = [self.prototype modelWithDictionary:@{ @"name": @"Foobar", @"bars": @1 }];

    STAssertEqualObjects(@"Foobar", [model objectAtKeyedSubscript:@"name"], @"Invalid name.");
    STAssertEqualObjects(@1, [model objectAtKeyedSubscript:@"bars"], @"Invalid bars.");
    STAssertNil(model._id, @"Invalid id");

    ASYNC_TEST_START
    [model saveWithSuccess:^{
        NSLog(@"Completed with: %@", model._id);
        lastId = model._id;
        STAssertNotNil(model._id, @"Invalid id");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRemove {
    ASYNC_TEST_START
    [self.prototype findWithId:lastId
                       success:^(LBModel *model) {
                           [model destroyWithSuccess:^{
                               ASYNC_TEST_SIGNAL
                           } failure:ASYNC_TEST_FAILURE_BLOCK];
                       } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFind {
    ASYNC_TEST_START
    [self.prototype findWithId:@2
                       success:^(LBModel *model) {
                           STAssertNotNil(model, @"No model found with ID 2");
                           STAssertTrue([[model class] isSubclassOfClass:[LBModel class]], @"Invalid class.");
                           STAssertEqualObjects([model objectAtKeyedSubscript:@"name"], @"Bar", @"Invalid name");
                           STAssertEqualObjects([model objectAtKeyedSubscript:@"bars"], @1, @"Invalid bars");
                           ASYNC_TEST_SIGNAL
                       } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testAll {
    ASYNC_TEST_START
    [self.prototype allWithSuccess:^(NSArray *models) {
        STAssertNotNil(models, @"No models returned.");
        STAssertTrue([models count] >= 2, [NSString stringWithFormat:@"Invalid # of models returned: %lu", (unsigned long)[models count]]);
        STAssertTrue([[models[0] class] isSubclassOfClass:[LBModel class]], @"Invalid class.");
        STAssertEqualObjects([models[0] objectAtKeyedSubscript:@"name"], @"Foo", @"Invalid name");
        STAssertEqualObjects([models[0] objectAtKeyedSubscript:@"bars"], @0, @"Invalid bars");
        STAssertEqualObjects([models[1] objectAtKeyedSubscript:@"name"], @"Bar", @"Invalid name");
        STAssertEqualObjects([models[1] objectAtKeyedSubscript:@"bars"], @1, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUpdate {
    ASYNC_TEST_START
    LBModelFindSuccessBlock verify = ^(LBModel *model) {
        STAssertNotNil(model, @"No model found with ID 2");
        STAssertEqualObjects([model objectAtKeyedSubscript:@"name"], @"Barfoo", @"Invalid name");
        STAssertEqualObjects([model objectAtKeyedSubscript:@"bars"], @1, @"Invalid bars");

        [model setObject:@"Bar" forKeyedSubscript:@"name"];
        [model saveWithSuccess:^{
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    };

    LBModelSaveSuccessBlock findAgain = ^() {
        [self.prototype findWithId:@2 success:verify failure:ASYNC_TEST_FAILURE_BLOCK];
    };

    LBModelFindSuccessBlock update = ^(LBModel *model) {
        STAssertNotNil(model, @"No model found with ID 2");
        [model setObject:@"Barfoo" forKeyedSubscript:@"name"];
        [model saveWithSuccess:findAgain failure:ASYNC_TEST_FAILURE_BLOCK];
    };

    [self.prototype findWithId:@2 success:update failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
