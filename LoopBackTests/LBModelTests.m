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

- (void)testCreation {
    LBModel *model = [self.prototype modelWithDictionary:@{ @"name": @"Foobar" }];

    STAssertEqualObjects(@"Foobar", [model objectAtKeyedSubscript:@"name"], @"Invalid name.");
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
        STAssertEquals([models count], (NSUInteger)2, [NSString stringWithFormat:@"Invalid # of models returned: %lu", (unsigned long)[models count]]);
        STAssertTrue([[models[0] class] isSubclassOfClass:[LBModel class]], @"Invalid class.");
        STAssertEqualObjects([models[0] objectAtKeyedSubscript:@"name"], @"Foo", @"Invalid name.");
        STAssertEqualObjects([models[0] objectAtKeyedSubscript:@"bars"], @0, @"Invalid bars: %@");
        STAssertEqualObjects([models[1] objectAtKeyedSubscript:@"name"], @"Bar", @"Invalid name: %@");
        STAssertEqualObjects([models[1] objectAtKeyedSubscript:@"bars"], @1, @"Invalid bars: %@");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
