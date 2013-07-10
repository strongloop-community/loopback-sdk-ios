//
//  SLAModelSubclassingTests.m
//  Asteroid
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "SLAModelSubclassingTests.h"

#import "SLAModel.h"
#import "SLARESTAdapter.h"

@interface Widget : SLAModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic) NSNumber *bars;

@end

@implementation Widget

@end

@interface WidgetPrototype : SLAModelPrototype

+ (instancetype)prototype;

@end

@implementation WidgetPrototype

+ (instancetype)prototype {
    return [self prototypeWithName:@"widgets"];
}

@end

@interface SLAModelSubclassingTests()

@property (nonatomic) WidgetPrototype *prototype;

@end

@implementation SLAModelSubclassingTests

- (void)setUp {
    [super setUp];

    SLARESTAdapter *adapter = [SLARESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.prototype = (WidgetPrototype *)[adapter prototypeWithClass:[WidgetPrototype class]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreation {
    Widget *model = (Widget*)[self.prototype modelWithDictionary:@{ @"name": @"Foobar", @"bars": @1 }];

    STAssertEqualObjects(model.name, @"Foobar", @"Invalid name.");
    STAssertEqualObjects(model.bars, @1, @"Invalid name.");
}

- (void)testFind {
    ASYNC_TEST_START
    [self.prototype findWithId:@2
                       success:^(SLAModel *model) {
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
    [self.prototype allWithSuccess:^(NSArray *models) {
        STAssertNotNil(models, @"No models returned.");
        STAssertEquals([models count], (NSUInteger)2, [NSString stringWithFormat:@"Invalid # of models returned: %lu", (unsigned long)[models count]]);
        STAssertTrue([[models[0] class] isSubclassOfClass:[Widget class]], @"Invalid class.");
        STAssertEqualObjects(((Widget *)models[0]).name, @"Foo", @"Invalid name.");
        STAssertEqualObjects(((Widget *)models[0]).bars, @0, @"Invalid bars: %@");
        STAssertEqualObjects(((Widget *)models[1]).name, @"Bar", @"Invalid name: %@");
        STAssertEqualObjects(((Widget *)models[1]).bars, @1, @"Invalid bars: %@");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
