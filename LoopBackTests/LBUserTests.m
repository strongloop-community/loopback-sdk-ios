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

/**
 * Custom subclass of User.
 */
@interface Customer : LBUser

@end

@implementation Customer

@end

/**
 * Repository for our custom User subclass.
 */
@interface CustomerRepository : LBUserRepository

+ (instancetype)repository;

@end

@implementation CustomerRepository

+ (instancetype)repository {
	return [self repositoryWithClassName:@"customers"];
}

@end


@interface LBUserTests ()

@property (nonatomic, strong) LBRESTAdapter *adapter;
@property (nonatomic, strong) CustomerRepository *repository;

@end

@implementation LBUserTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    SenTestSuite *suite = [SenTestSuite testSuiteWithName:@"TestSuite for LBContainer."];
    [suite addTest:[self testCaseWithSelector:@selector(testCreate)]];
    [suite addTest:[self testCaseWithSelector:@selector(testLogin)]];
    [suite addTest:[self testCaseWithSelector:@selector(testSetsCurrentUserIdOnLogin)]];
    [suite addTest:[self testCaseWithSelector:@selector(testCurrentUserIdIsStoredInSharedPreferences)]];
    [suite addTest:[self testCaseWithSelector:@selector(testLogout)]];
    [suite addTest:[self testCaseWithSelector:@selector(testClearsCurrentUserIdOnLogout)]];
    [suite addTest:[self testCaseWithSelector:@selector(testRemove)]];
    return suite;
}


- (void)setUp {
    [super setUp];
    
    self.adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = (CustomerRepository*)[self.adapter repositoryWithClass:[CustomerRepository class]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreate {
    ASYNC_TEST_START
    Customer __block *user = (Customer*)[self.repository createUserWithEmail:@"testUser@test.com"
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

- (void)testSetsCurrentUserIdOnLogin {
    ASYNC_TEST_START
    [self.repository userByLoginWithEmail:@"testUser@test.com" password:@"test" success:^(LBUser* user) {
        STAssertEqualObjects(user._id, self.repository.currentUserId, @"Invalid current user ID");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testCurrentUserIdIsStoredInSharedPreferences {
    ASYNC_TEST_START
    [self.repository userByLoginWithEmail:@"testUser@test.com" password:@"test" success:^(LBUser* user) {
        CustomerRepository *anotherRepo = (CustomerRepository*)[self.adapter repositoryWithClass:[CustomerRepository class]];
        STAssertEqualObjects(user._id, anotherRepo.currentUserId, @"Invalid current user ID");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testLogout {
    ASYNC_TEST_START
    [self.repository userByLoginWithEmail:@"testUser@test.com" password:@"test" success:^(LBUser* user) {
        [self.repository logoutWithSuccess:^(void) {
            // The following second try to logout should fail if the first logout succeeded
            [self.repository logoutWithSuccess:ASYNC_TEST_FAILURE_BLOCK
            failure:^(NSError *error) {
                ASYNC_TEST_SIGNAL
            }];
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testClearsCurrentUserIdOnLogout {
    ASYNC_TEST_START
    [self.repository userByLoginWithEmail:@"testUser@test.com" password:@"test" success:^(LBUser* user) {
        STAssertEqualObjects(user._id, self.repository.currentUserId, @"Invalid current user ID");
        [self.repository logoutWithSuccess:^(void) {
            STAssertEqualObjects(nil, self.repository.currentUserId, @"Invalid current user ID");
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
