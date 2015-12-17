//
//  LBUserTests.m
//  LoopBack
//
//  Created by Stephen Hess on 2/7/14.
//  Copyright (c) 2014 StrongLoop. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LBUser.h"
#import "LBRESTAdapter.h"
#import "SLRemotingTestsUtils.h"

static NSString * const DEFAULTS_CURRENT_USER_ID_KEY = @"LBUserRepositoryCurrentUserId";
static NSString * const USER_EMAIL_DOMAIN = @"@test.com";
static NSString * const USER_PASSWORD = @"testpassword";

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

@end

@implementation CustomerRepository

+ (instancetype)repository {
	return [self repositoryWithClassName:@"customers"];
}

@end


@interface LBUserTests : XCTestCase

@property (nonatomic, strong) LBRESTAdapter *adapter;
@property (nonatomic, strong) CustomerRepository *repository;

typedef void (^GivenCustomerSuccessBlock)(Customer *customer);
- (void)givenCustomerWithSuccess:(GivenCustomerSuccessBlock)success failure:(SLFailureBlock)failure;
- (void)givenLoggedInCustomerWithSuccess:(GivenCustomerSuccessBlock)success failure:(SLFailureBlock)failure;

@end

@implementation LBUserTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"TestSuite for LBContainer."];
    [suite addTest:[self testCaseWithSelector:@selector(testCreateSaveRemove)]];
    [suite addTest:[self testCaseWithSelector:@selector(testLoginLogout)]];
    [suite addTest:[self testCaseWithSelector:@selector(testResetPassword)]];
    [suite addTest:[self testCaseWithSelector:@selector(testSetsCurrentUserIdOnLogin)]];
    [suite addTest:[self testCaseWithSelector:@selector(testCurrentUserIdIsStoredInSharedPreferences)]];
    [suite addTest:[self testCaseWithSelector:@selector(testClearsCurrentUserIdOnLogout)]];
    [suite addTest:[self testCaseWithSelector:@selector(testGetCachedCurrentUserReturnsNilInitially)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFindCurrentUserReturnsNilWhenNotLoggedIn)]];
    [suite addTest:[self testCaseWithSelector:@selector(testFindCurrentUserReturnsCorrectValue)]];
    [suite addTest:[self testCaseWithSelector:@selector(testGetCachedCurrentUserReturnsValueLoadedByFindCurrentUser)]];
    [suite addTest:[self testCaseWithSelector:@selector(testGetCachedCurrentUserReturnsValueLoadedByLogin)]];
    [suite addTest:[self testCaseWithSelector:@selector(testCachedCurrentUserIsClearedOnLogout)]];
    return suite;
}

- (void)setUp {
    [super setUp];
    // forcibly clear the stored user id
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:DEFAULTS_CURRENT_USER_ID_KEY];

    self.adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = (CustomerRepository*)[self.adapter repositoryWithClass:[CustomerRepository class]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateSaveRemove {
    ASYNC_TEST_START
    double uid = [[NSDate date] timeIntervalSince1970];
    NSString *userEmail = [NSString stringWithFormat:@"%f%@", uid, USER_EMAIL_DOMAIN];

    Customer __block *customer = (Customer*)[self.repository createUserWithEmail:userEmail
                                                                        password:USER_PASSWORD];
    XCTAssertNil(customer._id, @"User id should be nil before save");

    [customer saveWithSuccess:^{
        XCTAssertNotNil(customer._id, @"User id should not be nil after save");

        [self.repository userByLoginWithEmail:userEmail password:USER_PASSWORD success:^(LBUser *user) {
            [user destroyWithSuccess:^(void) {
                ASYNC_TEST_SIGNAL
            } failure:ASYNC_TEST_FAILURE_BLOCK];
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testLoginLogout {
    ASYNC_TEST_START
    [self givenCustomerWithSuccess:^(Customer *customer) {
        [self.repository userByLoginWithEmail:customer.email password:USER_PASSWORD success:^(LBUser *user) {
            XCTAssertNotNil(user, @"User should not be nil");
            XCTAssertNotNil(user._id, @"User id should not be nil");
            XCTAssertEqualObjects(user.email, customer.email, @"Invalid email");

            [self.repository logoutWithSuccess:^(void) {
                ASYNC_TEST_SIGNAL
            } failure:ASYNC_TEST_FAILURE_BLOCK];
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testResetPassword {
    ASYNC_TEST_START
    [self givenCustomerWithSuccess:^(Customer *customer) {
        [self.repository resetPasswordWithEmail:customer.email success:^{
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testSetsCurrentUserIdOnLogin {
    ASYNC_TEST_START
    [self givenLoggedInCustomerWithSuccess:^(Customer *customer) {
        XCTAssertEqualObjects(customer._id, self.repository.currentUserId, @"Invalid current user ID");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testCurrentUserIdIsStoredInSharedPreferences {
    ASYNC_TEST_START
    [self givenLoggedInCustomerWithSuccess:^(Customer *customer) {
        CustomerRepository *anotherRepo = (CustomerRepository*)[self.adapter repositoryWithClass:[CustomerRepository class]];
        XCTAssertEqualObjects(customer._id, anotherRepo.currentUserId, @"Invalid current user ID");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testClearsCurrentUserIdOnLogout {
    ASYNC_TEST_START
    [self givenLoggedInCustomerWithSuccess:^(Customer *customer) {
        XCTAssertEqualObjects(customer._id, self.repository.currentUserId, @"Invalid current user ID");
        [self.repository logoutWithSuccess:^(void) {
            XCTAssertNil(self.repository.currentUserId, @"Invalid current user ID");
            // The following second try to logout should fail if the first logout succeeded
            [self.repository logoutWithSuccess:ASYNC_TEST_FAILURE_BLOCK
                                       failure:^(NSError *error) {
                                           ASYNC_TEST_SIGNAL
                                       }];
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testGetCachedCurrentUserReturnsNilInitially {
    LBUser *cached = self.repository.cachedCurrentUser;
    XCTAssertNil(cached, @"Cached current user should be nil initially");
}

- (void)testFindCurrentUserReturnsNilWhenNotLoggedIn {
    ASYNC_TEST_START
    [self.repository findCurrentUserWithSuccess:^(LBUser *current) {
        XCTAssertNil(current, @"Current user should be nil when not logged in");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testFindCurrentUserReturnsCorrectValue {
    ASYNC_TEST_START
    [self givenLoggedInCustomerWithSuccess:^(Customer *customer) {
        [self.repository findCurrentUserWithSuccess:^(LBUser *current) {
            XCTAssertEqualObjects(customer._id, current._id, @"Invalid current user");
            XCTAssertEqualObjects(customer.email, current.email, @"Invalid current user");
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testGetCachedCurrentUserReturnsValueLoadedByFindCurrentUser {
    ASYNC_TEST_START
    [self givenLoggedInCustomerWithSuccess:^(Customer *customer) {
        [self.repository findCurrentUserWithSuccess:^(LBUser *current) {
            LBUser *cached = self.repository.cachedCurrentUser;
            XCTAssertEqualObjects(current, cached, @"Invalid cached current user");
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testGetCachedCurrentUserReturnsValueLoadedByLogin {
    ASYNC_TEST_START
    [self givenLoggedInCustomerWithSuccess:^(Customer *customer) {
        LBUser *cached = self.repository.cachedCurrentUser;
        XCTAssertEqualObjects(customer, cached, @"Invalid cached current user");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testCachedCurrentUserIsClearedOnLogout {
    ASYNC_TEST_START
    [self givenLoggedInCustomerWithSuccess:^(Customer *customer) {
        [self.repository logoutWithSuccess:^(void) {
            LBUser *cached = self.repository.cachedCurrentUser;
            XCTAssertNil(cached, @"Cached current user should be nil after logout");
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)givenCustomerWithSuccess:(GivenCustomerSuccessBlock)success
                         failure:(SLFailureBlock)failure {
    static int counter = 0;

    double uid = [[NSDate date] timeIntervalSince1970];
    NSString *email = [NSString stringWithFormat:@"%f-%d%@", uid, ++counter, USER_EMAIL_DOMAIN];

    Customer __block *user = (Customer*)[self.repository createUserWithEmail:email password:USER_PASSWORD];
    [user saveWithSuccess:^{
        success(user);
    } failure:^(NSError *error) {
        NSLog(@"givenCustomerWithSuccess failed with error: %@", error);
        failure(error);
    }];
}

- (void)givenLoggedInCustomerWithSuccess:(GivenCustomerSuccessBlock)success
                                 failure:(SLFailureBlock)failure {
    [self givenCustomerWithSuccess:^(Customer *customer) {
        [self.repository userByLoginWithEmail:customer.email password:USER_PASSWORD success:^(LBUser *user) {
            success((Customer*)user);
        } failure:^(NSError *error) {
            NSLog(@"givenLoggedInCustomerWithSuccess failed with error: %@", error);
            failure(error);
        }];
    } failure:failure];
}

@end
