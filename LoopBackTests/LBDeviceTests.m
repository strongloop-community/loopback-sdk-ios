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

static NSNumber *lastId = nil;

@interface LBDeviceTests()

@property (nonatomic) LBDeviceRepository *repository;

@end

@implementation LBDeviceTests

- (void)setUp {
    [super setUp];
    
    LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = (LBDeviceRepository *) [adapter repositoryWithModelClass:[LBDeviceRepository class]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)test1Register {
    ASYNC_TEST_START
    unsigned char bytes[] = {
        0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    [LBDevice registerDevice: (LBRESTAdapter *)self.repository.adapter
                 deviceToken:data
              registrationId:lastId
                       appId:@"testapp"
                  appVersion:@"1.0"
                      userId:@"somebody"
                       badge: @1
                     success:^(LBDevice *model) {
                         // NSLog(@"Completed with: %@", model._id);
                         lastId = model._id;
                         STAssertNotNil(model._id, @"Invalid id");
                         ASYNC_TEST_SIGNAL
                     } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}


- (void)test2Find {
    ASYNC_TEST_START
    [self.repository findById:@1
                      success:^(LBModel *model) {
                          STAssertNotNil(model, @"No model found with ID 1");
                          STAssertTrue([[model class] isSubclassOfClass:[LBDevice class]], @"Invalid class.");
                          ASYNC_TEST_SIGNAL
                      } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}


- (void)test3All {
    ASYNC_TEST_START
    [self.repository allWithSuccess:^(NSArray *models) {
        STAssertNotNil(models, @"No models returned.");
        STAssertTrue([models count] >= 1, [NSString stringWithFormat:@"Invalid # of models returned: %lu", (unsigned long)[models count]]);
        // STAssertTrue([[models[0] class] isSubclassOfClass:[LBDevice class]], @"Invalid class.");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)test4ReRegister {
    ASYNC_TEST_START
    unsigned char bytes[] = {
        0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f};
    NSData *data = [NSData dataWithBytes:bytes length:sizeof(bytes)];
    
    [LBDevice registerDevice: (LBRESTAdapter *)self.repository.adapter
                 deviceToken:data
              registrationId:lastId
                       appId:@"testapp"
                  appVersion:@"1.0"
                      userId:@"somebody"
                       badge: @1
                    success:^(LBDevice *model) {
                        // NSLog(@"Completed with: %@", model._id);
                        lastId = model._id;
                        STAssertNotNil(model._id, @"Invalid id");
                        ASYNC_TEST_SIGNAL
                    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}


- (void)test5Remove {
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
