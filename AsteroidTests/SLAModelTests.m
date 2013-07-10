//
//  SLAModelTests.m
//  Asteroid
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLAModelTests.h"

#import "SLAModel.h"
#import "SLARESTAdapter.h"

@interface SLAModelTests()

@property (nonatomic) SLAModelPrototype *prototype;

@end

@implementation SLAModelTests

- (void)setUp {
    [super setUp];

    SLARESTAdapter *adapter = [SLARESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.prototype = [adapter prototypeWithName:@"widgets"];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreation {
    SLAModel *model = [self.prototype modelWithDictionary:@{ @"name": @"Foobar" }];

    STAssertEqualObjects(@"Foobar", [model objectAtKeyedSubscript:@"name"], @"Invalid name.");
}

- (void)testFind {
    ASYNC_TEST_START
    [self.prototype findWithId:@2
                       success:^(SLAModel *model) {
                           STAssertNotNil(model, @"No model found with ID 2");
                           STAssertTrue([[model class] isSubclassOfClass:[SLAModel class]], @"Invalid class.");
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
        STAssertTrue([[models[0] class] isSubclassOfClass:[SLAModel class]], @"Invalid class.");
        STAssertEqualObjects([models[0] objectAtKeyedSubscript:@"name"], @"Foo", @"Invalid name.");
        STAssertEqualObjects([models[0] objectAtKeyedSubscript:@"bars"], @0, @"Invalid bars: %@");
        STAssertEqualObjects([models[1] objectAtKeyedSubscript:@"name"], @"Bar", @"Invalid name: %@");
        STAssertEqualObjects([models[1] objectAtKeyedSubscript:@"bars"], @1, @"Invalid bars: %@");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
