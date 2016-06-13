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
// a Number property can be accessed via NSNumber or numeric primitive types.
@property (nonatomic) NSNumber *bars;
@property NSInteger bars2;
// a Boolean property can be accessed via NSNumber or the primitive type BOOL.
@property (nonatomic) NSNumber *flag;
@property BOOL flag2;
@property (nonatomic) NSDictionary *data;
@property (nonatomic) NSArray *stringArray;
@property (nonatomic) NSDate *date;
@property (nonatomic) NSData *buffer;
@property (nonatomic) CLLocation *geopoint;

@end

@implementation Widget

@end

@interface WidgetRepository : LBPersistedModelRepository

@end

@implementation WidgetRepository

+ (instancetype)repository {
    return [self repositoryWithClassName:@"widgets"];
}

- (SLRESTContract *)contract {
    SLRESTContract *contract = [super contract];

    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/testDate", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.testDate", self.className]];

    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/testBuffer", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.testBuffer", self.className]];

    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/testGeoPoint", self.className] verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.testGeoPoint", self.className]];

    return contract;
}

- (void)testMethodWithDate:(NSDate *)date
                   success:(void (^)(NSDate *date))success
                   failure:(SLFailureBlock)failure {

    [self invokeStaticMethod:@"testDate"
                  parameters:@{ @"date": date }
                     success:^(id value) {
                         NSDictionary *ret = value[@"date"];
                         NSAssert(ret, @"Invalid format: No value for key 'date' found: %@", value);
                         NSDate *date = [SLObject dateFromEncodedArgument:ret];
                         success(date);
                     }
                     failure:failure];
}

- (void)testMethodWithData:(NSData *)data
                   success:(void (^)(NSData *data))success
                   failure:(SLFailureBlock)failure {

    [self invokeStaticMethod:@"testBuffer"
                  parameters:@{ @"buffer": data }
                     success:^(id value) {
                         NSDictionary *ret = value[@"buffer"];
                         NSAssert(ret, @"Invalid format: No value for key 'buffer' found: %@", value);
                         NSData *data = [SLObject dataFromEncodedArgument:ret];
                         success(data);
                     }
                     failure:failure];
}

- (void)testmethodWithLocation:(CLLocation *)location
                       success:(void (^)(CLLocation *location))success
                       failure:(SLFailureBlock)failure {

    [self invokeStaticMethod:@"testGeoPoint"
                  parameters:@{ @"geopoint": location }
                     success:^(id value) {
                         NSDictionary *ret = value[@"geopoint"];
                         NSAssert(ret, @"Invalid format: No value for key 'geopoint' found: %@", value);
                         CLLocation *location = [SLObject locationFromEncodedArgument:ret];
                         success(location);
                     }
                     failure:failure];
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
    [suite addTest:[self testCaseWithSelector:@selector(testPropertyDataTypes)]];
    [suite addTest:[self testCaseWithSelector:@selector(testMethodDateArgAndRetValue)]];
    [suite addTest:[self testCaseWithSelector:@selector(testMethodBufferArgAndRetValue)]];
    [suite addTest:[self testCaseWithSelector:@selector(testMethodGeoPointArgAndRetValue)]];
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
    Widget *widget = (Widget*)[self.repository modelWithDictionary: @{
        @"name": @"Foobar",
        @"bars": @1
    }];

    XCTAssertEqualObjects(widget.name, @"Foobar", @"Invalid name.");
    XCTAssertEqualObjects(widget.bars, @1, @"Invalid bars.");
    XCTAssertNil(widget._id, @"Invalid id");

    ASYNC_TEST_START
    [widget saveWithSuccess:^{
        NSLog(@"Completed with: %@", widget._id);
        XCTAssertNotNil(widget._id, @"Invalid id");
        lastId = widget._id;
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFind {
    ASYNC_TEST_START
    [self.repository findById:@2
                      success:^(LBPersistedModel *model) {
        XCTAssertNotNil(model, @"No model found with ID 2");
        XCTAssertTrue([model isMemberOfClass:[Widget class]], @"Invalid class.");
        Widget *widget = (Widget *)model;
        XCTAssertEqualObjects(widget.name, @"Bar", @"Invalid name");
        XCTAssertEqualObjects(widget.bars, @1, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testAll {
    ASYNC_TEST_START
    [self.repository allWithSuccess:^(NSArray *models) {
        XCTAssertNotNil(models, @"No models returned.");
        XCTAssertTrue([models count] >= 2, @"Invalid # of models returned: %lu", (unsigned long)[models count]);
        XCTAssertTrue([models[0] isMemberOfClass:[Widget class]], @"Invalid class.");
        XCTAssertTrue([models[1] isMemberOfClass:[Widget class]], @"Invalid class.");
        XCTAssertEqualObjects(((Widget *)models[0]).name, @"Foo", @"Invalid name.");
        XCTAssertEqualObjects(((Widget *)models[0]).bars, @0, @"Invalid bars");
        XCTAssertEqualObjects(((Widget *)models[1]).name, @"Bar", @"Invalid name");
        XCTAssertEqualObjects(((Widget *)models[1]).bars, @1, @"Invalid bars");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUpdate {
    Widget *widget = (Widget*)[self.repository model];
    widget.name = @"Foobar";
    widget.bars = @123;

    ASYNC_TEST_START
    [widget saveWithSuccess:^{
        NSNumber *tempId = widget._id;
        // find the model just created
        [self.repository findById:tempId success:^(LBPersistedModel *model) {
            XCTAssertNotNil(model, @"No model found");
            XCTAssertTrue([model isMemberOfClass:[Widget class]], @"Invalid class.");
            Widget *widget = (Widget *)model;
            // update
            widget.name = @"Barfoo";
            [widget saveWithSuccess:^() {
                // find again
                [self.repository findById:tempId success:^(LBPersistedModel *model) {
                    XCTAssertNotNil(model, @"No model found");
                    XCTAssertTrue([model isMemberOfClass:[Widget class]], @"Invalid class.");
                    Widget *widget = (Widget *)model;
                    // verify
                    XCTAssertEqualObjects(widget.name, @"Barfoo", @"Invalid name");
                    XCTAssertEqualObjects(widget.bars, @123, @"Invalid bars");
                    // remove
                    [widget destroyWithSuccess:^() {
                        ASYNC_TEST_SIGNAL
                    } failure:ASYNC_TEST_FAILURE_BLOCK];
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

- (void)testPropertyDataTypes {
    Widget *widget = (Widget*)[self.repository modelWithDictionary: nil];
    widget.name = @"Foobar";
    widget.bars = @123;
    widget.bars2 = 456;
    widget.flag = @YES;
    widget.flag2 = NO;
    widget.data = @{ @"data1": @1, @"data2": @2 };
    widget.stringArray = @[ @"one", @"two", @"three" ];
    widget.date = [NSDate dateWithTimeIntervalSince1970:123];
    const char bufferBytes[] = { 12, 34, 56 };
    NSData *testData = [NSData dataWithBytes:bufferBytes length:sizeof(bufferBytes)];
    widget.buffer = testData;
    widget.geopoint = [[CLLocation alloc] initWithLatitude:12.3 longitude:45.6];

    ASYNC_TEST_START
    [widget saveWithSuccess:^{
        NSNumber *tempId = widget._id;
        [self.repository findById:tempId success:^(LBPersistedModel *model) {
            XCTAssertNotNil(model, @"No model found");
            XCTAssertTrue([model isMemberOfClass:[Widget class]], @"Invalid class.");
            Widget *widget = (Widget *)model;
            XCTAssertEqual(widget._id, tempId, @"Invalid id");
            XCTAssertEqualObjects(widget.name, @"Foobar", @"Invalid name.");
            XCTAssertEqualObjects(widget.bars, @123, @"Invalid bars.");
            XCTAssertEqual(widget.bars2, 456, @"Invalid bars2.");
            XCTAssertEqualObjects(widget.flag, @YES, @"Invalid flag.");
            XCTAssertEqual(widget.flag2, NO, @"Invalid flag2.");
            XCTAssertEqualObjects(widget.data, (@{ @"data1": @1, @"data2": @2 }), @"Invalid data.");
            XCTAssertEqualObjects(widget.stringArray, (@[ @"one", @"two", @"three" ]), @"Invalid array.");
            XCTAssertEqualObjects(widget.date, [NSDate dateWithTimeIntervalSince1970:123], @"Invalid date.");
            // TODO: this test is somehow flaky
            // XCTAssertEqualObjects(widget.buffer, testData, @"Invalid buffer.");
            XCTAssertEqual(widget.geopoint.coordinate.latitude, 12.3, @"Invalid latitude.");
            XCTAssertEqual(widget.geopoint.coordinate.longitude, 45.6, @"Invalid longitude.");

            [widget destroyWithSuccess:^{
                ASYNC_TEST_SIGNAL
            } failure:ASYNC_TEST_FAILURE_BLOCK];
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

// The following three tests check special handling for method argument encoding/decoding
// for Date, Buffer and GeoPoint data types.
// Although such encoding/decoding are done in SLObject, these tests are located here for the
// convenience of testing data type handling together with the above property encoding/decoding.

- (void)testMethodDateArgAndRetValue {
    ASYNC_TEST_START
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:123];
    [self.repository testMethodWithDate:(NSDate *)date success:^(NSDate *retDate) {
        // The test methods returns the date advanced from the given date by 1 second.
        XCTAssertEqualObjects(retDate, [NSDate dateWithTimeIntervalSince1970:124], @"Invalid date.");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testMethodBufferArgAndRetValue {
    ASYNC_TEST_START
    const char bufferBytes[] = { 01, 02, 03 };
    NSMutableData *data = [NSMutableData dataWithBytes:bufferBytes length:sizeof(bufferBytes)];
    [self.repository testMethodWithData:(NSData *)data success:^(NSData *retData) {
        // The test method returns the given buffer after incrementing all the bytes by 1.
        const char expectedBytes[] = { 02, 03, 04 };
        NSMutableData *expectedData = [NSMutableData dataWithBytes:expectedBytes length:sizeof(expectedBytes)];
        XCTAssertEqualObjects(retData, expectedData, @"Invalid data.");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testMethodGeoPointArgAndRetValue {
    ASYNC_TEST_START
    CLLocation *location = [[CLLocation alloc] initWithLatitude:1.23 longitude:4.56];
    [self.repository testmethodWithLocation:location success:^(CLLocation *retLocation) {
        // The test method returns a location object with lat +1 and lng +1 of the given object.
        // Note that only the lat and the lng values are sent to/from the server.
        XCTAssertEqual(retLocation.coordinate.latitude, 2.23, @"Invalid latitude.");
        XCTAssertEqual(retLocation.coordinate.longitude, 5.56, @"Invalid latitude.");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
