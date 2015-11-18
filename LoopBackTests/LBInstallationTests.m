//
//  LBInstallationTests.m
//  LoopBack
//
//  Created by Michael Schoonmaker on 6/19/13.
//  Copyright (c) 2013 StrongLoop. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LBInstallation.h"
#import "SLRemotingTestsUtils.h"

static id lastId = nil;

@interface LBInstallationTests : XCTestCase

@property (nonatomic) LBInstallationRepository *repository;
@property (nonatomic) NSData *testToken;

@end

@implementation LBInstallationTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"TestSuite for LBInstallation."];
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
    self.repository = (LBInstallationRepository *) [adapter repositoryWithClass:[LBInstallationRepository class]];
    
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
    LBInstallationRepository* r1 = [LBInstallationRepository repository];
    LBInstallationRepository* r2 = [LBInstallationRepository repository];
    XCTAssertEqual(r1, r2, @"LBInstallationRepository.repository is a singleton");
}

- (void)testRegister {
    ASYNC_TEST_START
    
    [LBInstallation registerDeviceWithAdapter: (LBRESTAdapter *)self.repository.adapter
                                  deviceToken:self.testToken
                               registrationId:lastId
                                        appId:@"testapp"
                                   appVersion:@"1.0"
                                       userId:@"user1"
                                        badge:@1
                                subscriptions:nil
                                      success:^(LBInstallation *model) {
                                          // NSLog(@"Completed with: %@", model._id);
                                          lastId = model._id;
                                          XCTAssertNotNil(model._id, @"Invalid id");
                                          ASYNC_TEST_SIGNAL
                                      }
                                      failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}


- (void)testFind {
    ASYNC_TEST_START
    [self.repository findById:lastId
                      success:^(LBModel *model) {
                          XCTAssertNotNil(model, @"No model found with ID 1");
                          XCTAssertTrue([[model class] isSubclassOfClass:[LBInstallation class]], @"Invalid class.");
                          ASYNC_TEST_SIGNAL
                      } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testAll {
    ASYNC_TEST_START
    [self.repository allWithSuccess:^(NSArray *models) {
        XCTAssertNotNil(models, @"No models returned.");
        XCTAssertTrue([models count] >= 1, @"Invalid # of models returned: %lu", (unsigned long)[models count]);
        // STAssertTrue([[models[0] class] isSubclassOfClass:[LBInstallation class]], @"Invalid class.");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testReRegister {
    ASYNC_TEST_START
    
    [LBInstallation registerDeviceWithAdapter: (LBRESTAdapter *)self.repository.adapter
                                  deviceToken:self.testToken
                               registrationId:lastId
                                        appId:@"testapp"
                                   appVersion:@"1.0"
                                       userId:@"user2"
                                        badge:@1
                                subscriptions:nil
                                      success:^(LBInstallation *model) {
                                          // NSLog(@"Completed with: %@ %@", model._id, [model._id class]);
                                          // NSLog(@"Completed with: %@ %@", lastId, [lastId class]);
                                          // [rfeng] We have to do NSString comparision
                                          id id1 = model._id;
                                          id id2 = lastId;
                                          XCTAssertTrue([id1 isEqualToValue:id2], @"The ids should be the same");
                                          lastId = model._id;
                                          XCTAssertNotNil(model._id, @"Invalid id");
                                          ASYNC_TEST_SIGNAL
                                      }
                                      failure:ASYNC_TEST_FAILURE_BLOCK];
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
