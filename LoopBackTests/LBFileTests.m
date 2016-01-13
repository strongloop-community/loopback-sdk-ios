//
//  LBFileTests.m
//  LoopBack
//
//  Created by Stephen Hess on 2/7/14.
//  Copyright (c) 2014 StrongLoop. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "LBFile.h"
#import "LBRESTAdapter.h"
#import "SLRemotingTestsUtils.h"

@interface LBFileTests : XCTestCase

@property (nonatomic) LBFileRepository *repository;

@end

@implementation LBFileTests

/**
 * Create the default test suite to control the order of test methods
 */
+ (id)defaultTestSuite {
    XCTestSuite *suite = [XCTestSuite testSuiteWithName:@"TestSuite for LBFile."];
    [suite addTest:[self testCaseWithSelector:@selector(testGetByName)]];
    [suite addTest:[self testCaseWithSelector:@selector(testGetAllFiles)]];
    [suite addTest:[self testCaseWithSelector:@selector(testDownload)]];
    [suite addTest:[self testCaseWithSelector:@selector(testDownloadWithOutputStream)]];
    [suite addTest:[self testCaseWithSelector:@selector(testDownloadAsData)]];
    [suite addTest:[self testCaseWithSelector:@selector(testUpload)]];
    [suite addTest:[self testCaseWithSelector:@selector(testUploadFromInputStream)]];
    [suite addTest:[self testCaseWithSelector:@selector(testUploadFromData)]];
    [suite addTest:[self testCaseWithSelector:@selector(testDelete)]];
    return suite;
}


- (void)setUp {
    [super setUp];
    
    LBRESTAdapter *adapter = [LBRESTAdapter adapterWithURL:[NSURL URLWithString:@"http://localhost:3000"]];
    self.repository = (LBFileRepository*)[adapter repositoryWithClass:[LBFileRepository class]];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetByName {
    NSString *fileName = @"f1.txt";
    NSString *container = @"container1";
    NSString *tmpDir = NSTemporaryDirectory();

    ASYNC_TEST_START
    [self.repository getFileWithName:fileName
                           localPath:tmpDir
                           container:container
                             success:^(LBFile *file) {
        XCTAssertNotNil(file, @"File not found.");
        XCTAssertEqualObjects(file.name, fileName, @"Invalid name");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testGetAllFiles {
    NSString *container = @"container1";

    ASYNC_TEST_START
    [self.repository getAllFilesWithContainer: container
                                      success:^(NSArray *files) {
        XCTAssertNotNil(files, @"No file returned.");
        XCTAssertTrue(files.count >= 2,
                      @"Invalid # of files returned: %lu", (unsigned long)files.count);
        XCTAssertTrue([[files[0] class] isSubclassOfClass:[LBFile class]], @"Invalid class.");

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"f1.txt"];
        NSArray *filteredArray = [files filteredArrayUsingPredicate:predicate];
        XCTAssertTrue(filteredArray.count == 1, @"Failed to get file f1.txt");

        predicate = [NSPredicate predicateWithFormat:@"name == %@", @"f2.txt"];
        filteredArray = [files filteredArrayUsingPredicate:predicate];
        XCTAssertTrue(filteredArray.count == 1, @"Failed to get file f2.txt");

        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testDownload {
    NSString *fileName = @"f1.txt";
    NSString *container = @"container1";
    NSString *contents = @"f1.txt in container1";
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *fullPath = [tmpDir stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Remove it if it currently exists locally...
    if ([fileManager fileExistsAtPath:fullPath]) {
        [fileManager removeItemAtPath:fullPath error:nil];
    }
    
    ASYNC_TEST_START
    [self.repository getFileWithName:fileName
                           localPath:tmpDir
                           container:container
                             success:^(LBFile *file) {
        XCTAssertNotNil(file, @"File not found.");
        XCTAssertEqualObjects(file.name, fileName, @"Invalid name");
        [file downloadWithSuccess:^(void) {
            XCTAssertTrue([fileManager fileExistsAtPath:fullPath], @"File missing.");
            NSString *fileContents = [NSString stringWithContentsOfFile:fullPath
                                                               encoding:NSUTF8StringEncoding
                                                                  error:nil];
            XCTAssertEqualObjects(fileContents, contents, @"File corrupted");
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testDownloadWithOutputStream {
    NSString *fileName = @"f1.txt";
    NSString *container = @"container1";
    NSString *contents = @"f1.txt in container1";
    NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];

    ASYNC_TEST_START
    [self.repository downloadWithName:fileName
                            container:container
                         outputStream:outputStream
                              success:^() {
        NSData *data = [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
        [outputStream close];
        NSString *fileContents = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(fileContents, contents, @"File corrupted");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testDownloadAsData {
    NSString *fileName = @"f1.txt";
    NSString *container = @"container1";
    NSString *contents = @"f1.txt in container1";

    ASYNC_TEST_START
    [self.repository downloadAsDataWithName:fileName
                                  container:container
                                    success:^(NSData *data) {
        NSString *fileContents = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
        XCTAssertEqualObjects(fileContents, contents, @"File corrupted");
        ASYNC_TEST_SIGNAL
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUpload {
    NSString *fileName = @"uploadTest.txt";
    NSString *container = @"container1";
    NSString* contents = @"Upload test";
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *fullPath = [tmpDir stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    // Remove it if it currently exists...
    if ([fileManager fileExistsAtPath:fullPath]) {
        [fileManager removeItemAtPath:fullPath error:nil];
    }

    [contents writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

    LBFile *file = [self.repository createFileWithName:fileName
                                             localPath:tmpDir
                                             container:container];
    ASYNC_TEST_START
    [file uploadWithSuccess:^(LBFile *fileResponse) {
        XCTAssertEqualObjects(fileResponse.name, file.name);
        XCTAssertEqualObjects(fileResponse.container, file.container);
        
        [self.repository downloadAsDataWithName:fileName
                                      container:container
                                        success:^(NSData *data) {
            NSString *fileContents = [[NSString alloc] initWithData:data
                                                           encoding:NSUTF8StringEncoding];
            XCTAssertEqualObjects(fileContents, contents, @"File corrupted");
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUploadFromInputStream {
    NSString *fileName = @"uploadTest.txt";
    NSString *container = @"container1";
    NSString *contents = @"Testing upload from an NSInputStream";
    NSInputStream* inputStream =
        [NSInputStream inputStreamWithData:[contents dataUsingEncoding:NSUTF8StringEncoding]];
    NSUInteger bytes = [contents lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    ASYNC_TEST_START
    [self.repository uploadWithName:fileName
                          container:container
                        inputStream:inputStream
                        contentType:@"text/plain"
                             length:bytes
                            success:^(LBFile *fileResponse) {
                                XCTAssertEqualObjects(fileResponse.name, fileName);
                                XCTAssertEqualObjects(fileResponse.container, container);
        [self.repository downloadAsDataWithName:fileName
                                      container:container
                                        success:^(NSData *data) {
            NSString *fileContents = [[NSString alloc] initWithData:data
                                                            encoding:NSUTF8StringEncoding];
            XCTAssertEqualObjects(fileContents, contents, @"File corrupted");
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testUploadFromData {
    NSString *fileName = @"uploadTest.txt";
    NSString *container = @"container1";
    NSString *contents = @"Testing upload from an NSData";
    NSData *data = [contents dataUsingEncoding:NSUTF8StringEncoding];

    ASYNC_TEST_START
    [self.repository uploadWithName:fileName
                          container:container
                               data:data
                        contentType:@"text/plain"
                            success:^(LBFile *fileResponse) {
                                XCTAssertEqualObjects(fileResponse.name, fileName);
                                XCTAssertEqualObjects(fileResponse.container, container);
        [self.repository downloadAsDataWithName:fileName
                                      container:container
                                        success:^(NSData *data) {
            NSString *fileContents = [[NSString alloc] initWithData:data
                                                           encoding:NSUTF8StringEncoding];
            XCTAssertEqualObjects(fileContents, contents, @"File corrupted");
            ASYNC_TEST_SIGNAL
        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

- (void)testDelete {
    NSString *fileName = @"uploadTest.txt";
    NSString *container = @"container1";
    NSString *tmpDir = NSTemporaryDirectory();

    ASYNC_TEST_START
    [self.repository getFileWithName:fileName
                           localPath:tmpDir
                           container:container
                             success:^(LBFile *file) {
        XCTAssertNotNil(file, @"File not found.");
        XCTAssertEqualObjects(file.name, fileName, @"Invalid name");

        [file deleteWithSuccess:^(void) {

            [self.repository getFileWithName:fileName
                                   localPath:tmpDir
                                   container:container
                                     success:^(LBFile *file) {
                XCTFail(@"File found after deletion");
            } failure:^(NSError *err) {
                ASYNC_TEST_SIGNAL
            }];

        } failure:ASYNC_TEST_FAILURE_BLOCK];
    } failure:ASYNC_TEST_FAILURE_BLOCK];
    ASYNC_TEST_END
}

@end
