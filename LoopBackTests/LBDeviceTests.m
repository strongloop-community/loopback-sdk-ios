//
//  LBModelTests.m
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import "LBDeviceTests.h"

#import "LBModel.h"
#import "LBRESTAdapter.h"
#import "LBDevice.h"

static id lastId = nil;

@interface LBDeviceTests()

+ (id)defaultTestSuite;

@property (nonatomic) LBDeviceRepository *repository;
@property (nonatomic) NSData *testToken;

@end

@implementation LBDeviceTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    SenTestSuite *suite = [SenTestSuite testSuiteWithName:@"TestSuite for LBDevice."];
    [suite addTest:[self testCaseWithSelector:@selector(testSingletonRepository)]];
    [suite addTest:[self testCaseWithSelector:@selector(testRegister)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFind)]];
    [suite addTest:[self testCaseWithSelector:@selector(testAll)]];
    [suite addTest:[self testCaseWithSelector:@selector(testReRegister)]];
    [suite addTest:[self testCaseWithSelector:@selector(testRemove)]];
    return suite;
}

- (void)setUp {
    [super setUp];
    
    LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = (LBDeviceRepository *) [adapter repositoryWithModelClass:[LBDeviceRepository class]];
    
    unsigned char bytes[] = {
        0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f,
        0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f,
        0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f,
        0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f};
    self.testToken = [NSData dataWithBytes:bytes length:sizeof(bytes)];

}

- (void)tearDown {
    [super tearDown];
}

- (void)testSingletonRepository {
    LBDeviceRepository* r1 = [LBDeviceRepository repository];
    LBDeviceRepository* r2 = [LBDeviceRepository repository];
    STAssertEquals(r1, r2, @"LBDeviceRepository.repository is a singleton");
}

- (void)testRegister {
    ASYNC_TEST_START
    
    [LBDevice registerDeviceWithAdapter: (LBRESTAdapter *)self.repository.adapter
                 deviceToken:self.testToken
              registrationId:lastId
                       appId:@"testapp"
                  appVersion:@"1.0"
                      userId:@"user1"
                       badge:@1
                     success:^(LBDevice *model) {
                         // NSLog(@"Completed with: %@", model._id);
                         lastId = model._id;
                         STAssertNotNil(model._id, @"Invalid id");
                         ASYNC_TEST_SIGNAL
                     } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}


- (void)testFind {
    ASYNC_TEST_START
    [self.repository findById:lastId
                      success:^(LBModel *model) {
                          STAssertNotNil(model, @"No model found with ID 1");
                          STAssertTrue([[model class] isSubclassOfClass:[LBDevice class]], @"Invalid class.");
                          ASYNC_TEST_SIGNAL
                      } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testAll {
    ASYNC_TEST_START
    [self.repository allWithSuccess:^(NSArray *models) {
        STAssertNotNil(models, @"No models returned.");
        STAssertTrue([models count] >= 1, [NSString stringWithFormat:@"Invalid # of models returned: %lu", (unsigned long)[models count]]);
        // STAssertTrue([[models[0] class] isSubclassOfClass:[LBDevice class]], @"Invalid class.");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testReRegister {
    ASYNC_TEST_START
    
    [LBDevice registerDeviceWithAdapter: (LBRESTAdapter *)self.repository.adapter
                 deviceToken:self.testToken
              registrationId:lastId
                       appId:@"testapp"
                  appVersion:@"1.0"
                      userId:@"user2"
                       badge:@1
                    success:^(LBDevice *model) {
                        // NSLog(@"Completed with: %@ %@", model._id, [model._id class]);
                        // NSLog(@"Completed with: %@ %@", lastId, [lastId class]);
                        // [rfeng] We have to do NSString comparision
                        NSString *id1 = (NSString *) model._id;
                        NSString *id2 = (NSString *) lastId;
                        STAssertTrue([id1 isEqualToString:id2], @"The ids should be the same");
                        lastId = model._id;
                        STAssertNotNil(model._id, @"Invalid id");
                        ASYNC_TEST_SIGNAL
                    } failure:ASYNC_TEST_FAILURE_BLOCK];
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
