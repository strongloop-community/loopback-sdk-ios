/**
 * @file LBFile.m
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#if TARGET_OS_IPHONE
#import <MobileCoreServices/MobileCoreServices.h>
#endif
#import "LBFile.h"
#import "LBRESTAdapter.h"
#import "SLStreamParam.h"

static NSString *mimeTypeForFileName(NSString *fileName) {
    CFStringRef pathExtension = (__bridge_retained CFStringRef)[fileName pathExtension];
    CFStringRef type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                             pathExtension,
                                                             NULL);
    CFRelease(pathExtension);
    NSString *mimeType =
        (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass(type, kUTTagClassMIMEType);

    return (mimeType != nil) ? mimeType : @"application/octet-stream";
}

@implementation LBFile

- (void)uploadWithSuccess:(LBFileUploadSuccessBlock)success
                  failure:(SLFailureBlock)failure {

    NSString *fullLocalPath = [self.localPath stringByAppendingPathComponent:self.name];
    NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:fullLocalPath];
    NSString *mimeType = mimeTypeForFileName(self.name);
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullLocalPath
                                                                                error:NULL];
    NSInteger length = attributes.fileSize;

    __block SLStreamParam *streamParam = [SLStreamParam streamParamWithInputStream:inputStream
                                                                          fileName:self.name
                                                                       contentType:mimeType
                                                                            length:length];

   [self invokeMethod:@"upload"
           parameters:@{@"container": self.container,
                        @"name": self.name,
                        @"file": streamParam}
              success:^(id value) {
                  success();
              }
              failure:failure];
}

- (void)downloadWithSuccess:(LBFileDownloadSuccessBlock)success
                    failure:(SLFailureBlock)failure {
    NSString *fullLocalPath = [self.localPath stringByAppendingPathComponent:self.name];
    __block NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:fullLocalPath
                                                                             append:NO];
    
    [self invokeMethod:@"download"
            parameters:@{@"container": self.container,
                         @"name": self.name}
          outputStream:outputStream
               success:^(id value) {
                   success();
               }
               failure:failure];
}

@end

@implementation LBFileRepository

+ (instancetype)repository {
    LBFileRepository *repository = [self repositoryWithClassName:@"containers"];
    repository.modelClass = [LBFile class];
    return repository;
}

- (SLRESTContract *)contract {
    SLRESTContract *contract = [super contract];
    
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/upload", self.className]
                                                     verb:@"POST"
                                                multipart:YES]
            forMethod:[NSString stringWithFormat:@"%@.prototype.upload", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/download/:name", self.className]
                                                     verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.prototype.download", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/files/:name", self.className]
                                                     verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.get", self.className]];
    
    return contract;
}

- (LBFile *)createFileWithName:(NSString*)name
                     localPath:(NSString*)localPath
                     container:(NSString*)container {
    LBFile *file = (LBFile*)[self modelWithDictionary:@{@"name" : name, @"localPath" : localPath, @"container" : container}];
    return file;
}

- (void)getFileWithName:(NSString*)name
              localPath:(NSString*)localPath
              container:(NSString*)container
                success:(LBFileGetSuccessBlock)success
                failure:(SLFailureBlock)failure {
    NSParameterAssert(name);
    NSParameterAssert(container);
    [self invokeStaticMethod:@"get"
            parameters:@{@"name": name, @"localPath" : localPath, @"container" : container}
               success:^(id value) {
                   NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                   LBFile *file = (LBFile*)[self modelWithDictionary:value];
                   file.localPath = localPath;
                   success(file);
               } failure:failure];
}

@end