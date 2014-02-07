//
//  LBUserTests.m
//  LoopBack
//
//  Created by Stephen Hess on 2/7/14.
//  Copyright (c) 2014 StrongLoop. All rights reserved.
//

#import "LBUserTests.h"

#import "LBUser.h"
#import "LBRESTAdapter.h"

@interface LBUserTests ()

@property (nonatomic, strong) LBUserRepository *repository;

@end

@implementation LBUserTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    SenTestSuite *suite = [SenTestSuite testSuiteWithName:@"TestSuite for LBContainer."];
    [suite addTest:[self testCaseWithSelector:@selector(testCreate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testLogin)]];
    [suite addTest:[self testCaseWithSelector:@selector(testLogout)]];
    [suite addTest:[self testCaseWithSelector:@selector(testRemove)]];
    return suite;
}


- (void)setUp {
    [super setUp];
    
    LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000/api"]];
    self.repository = (LBUserRepository*)[adapter repositoryWithClass:[LBUserRepository class]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreate {
    ASYNC_TEST_START
    LBUser __block *user = [self.repository createUserWithEmail:@"testUser@test.com"
                                                       password:@"test"];
    [user saveWithSuccess:^{
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testLogin {
    ASYNC_TEST_START
    [self.repository userByLoginWithEmail:@"testUser@test.com" password:@"test" success:^(LBUser* user) {
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testLogout {
    ASYNC_TEST_START
    [self.repository userByLoginWithEmail:@"testUser@test.com" password:@"test" success:^(LBUser* user) {
        [self.repository logoutWithSuccess:^(void) {
        ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testRemove {
    ASYNC_TEST_START
    [self.repository userByLoginWithEmail:@"testUser@test.com" password:@"test" success:^(LBUser* user) {
        [user destroyWithSuccess:^(void) {
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
