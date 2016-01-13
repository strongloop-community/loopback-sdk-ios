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
            parameters:@{ @"container": self.container,
                          @"name": self.name,
                          @"file": streamParam }
               success:^(id value) {
                   NSAssert([[value class] isSubclassOfClass:[NSDictionary class]],
                            @"Received non-Dictionary: %@", value);
                   NSDictionary *fileDictionary = [(NSDictionary*)value valueForKeyPath:@"result.files.file"][0];
                   NSAssert(fileDictionary != nil, @"Empty Response from File Upload");
                   LBFile *file = (LBFile *)[(LBFileRepository *)[self repository] modelWithDictionary:fileDictionary];
                   success(file);
               }
               failure:failure];
}

- (void)downloadWithSuccess:(LBFileDownloadSuccessBlock)success
                    failure:(SLFailureBlock)failure {

    NSString *fullLocalPath = [self.localPath stringByAppendingPathComponent:self.name];
    __block NSOutputStream *outputStream = [NSOutputStream outputStreamToFileAtPath:fullLocalPath
                                                                             append:NO];
    
    [self invokeMethod:@"download"
            parameters:@{ @"container": self.container,
                          @"name": self.name }
          outputStream:outputStream
               success:^(id value) {
                   success();
               }
               failure:failure];
}

- (void)deleteWithSuccess:(LBFileDeleteSuccessBlock)success
                  failure:(SLFailureBlock)failure {
    
    [self invokeMethod:@"delete"
            parameters:@{ @"name": self.name,
                          @"container": self.container }
               success:^(id value) {
                   success();
               }
               failure:failure];
}

@end

@implementation LBFileRepository

+ (instancetype)repository {
    LBFileRepository *repository = [self repositoryWithClassName:@"containers"];
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
                                                     verb:@"DELETE"]
            forMethod:[NSString stringWithFormat:@"%@.prototype.delete", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/upload", self.className]
                                                     verb:@"POST"
                                                multipart:YES]
            forMethod:[NSString stringWithFormat:@"%@.upload", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/download/:name", self.className]
                                                     verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.download", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/files/:name", self.className]
                                                     verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.get", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/files", self.className]
                                                     verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.getAll", self.className]];

    return contract;
}

- (LBFile *)createFileWithName:(NSString *)name
                     localPath:(NSString *)localPath
                     container:(NSString *)container {
    
    LBFile *file = (LBFile *)[self modelWithDictionary:@{ @"name": name,
                                                          @"localPath": localPath,
                                                          @"container": container }];
    return file;
}

- (void)getFileWithName:(NSString *)name
              localPath:(NSString *)localPath
              container:(NSString *)container
                success:(LBFileGetSuccessBlock)success
                failure:(SLFailureBlock)failure {

    NSParameterAssert(name);
    NSParameterAssert(container);
    [self invokeStaticMethod:@"get"
            parameters:@{ @"name": name,
                          @"container": container }
               success:^(id value) {
                   NSAssert([[value class] isSubclassOfClass:[NSDictionary class]],
                            @"Received non-Dictionary: %@", value);
                   LBFile *file = (LBFile *)[self modelWithDictionary:value];
                   file.localPath = localPath;
                   success(file);
               } failure:failure];
}

- (void)getAllFilesWithContainer:(NSString *)container
                         success:(LBGetAllFilesSuccessBlock)success
                         failure:(SLFailureBlock)failure {

    [self invokeStaticMethod:@"getAll"
                  parameters:@{ @"container": container }
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSArray class]], @"Received non-Array: %@", value);
                         NSArray* response = (NSArray*)value;
                         NSMutableArray *files = [NSMutableArray arrayWithCapacity:response.count];
                         for (id respVal in response) {
                             NSAssert([[respVal class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", respVal);
                             LBFile *file = (LBFile*)[self modelWithDictionary:(NSDictionary*)respVal];
                             [files addObject:file];
                         }
                         success(files);
                     } failure:failure];
}

- (void)uploadWithName:(NSString *)name
             container:(NSString *)container
           inputStream:(NSInputStream *)inputStream
           contentType:(NSString *)contentType
                length:(NSInteger)length
               success:(LBFileUploadSuccessBlock)success
               failure:(SLFailureBlock)failure {

    SLStreamParam *streamParam = [SLStreamParam streamParamWithInputStream:inputStream
                                                                  fileName:name
                                                               contentType:contentType
                                                                    length:length];

    [self invokeStaticMethod:@"upload"
                  parameters:@{ @"name": name,
                                @"container": container,
                                @"file": streamParam }
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]],
                                  @"Received non-Dictionary: %@", value);
                         NSDictionary *fileDictionary = [(NSDictionary*)value valueForKeyPath:@"result.files.file"][0];
                         NSAssert(fileDictionary != nil, @"Empty Response from File Upload");
                         LBFile *file = (LBFile *)[self modelWithDictionary:fileDictionary];
                         success(file);
                     }
                     failure:failure];
}

- (void)uploadWithName:(NSString *)name
             container:(NSString *)container
                  data:(NSData *)data
           contentType:(NSString *)contentType
               success:(LBFileUploadSuccessBlock)success
               failure:(SLFailureBlock)failure {

    NSInputStream *inputStream = [[NSInputStream alloc] initWithData:data];

    [self uploadWithName:name
               container:container
             inputStream:inputStream
             contentType:contentType
                  length:data.length
                 success:success
                 failure:failure];
}

- (void)downloadWithName:(NSString *)name
               container:(NSString *)container
            outputStream:(NSOutputStream *)outputStream
                 success:(LBFileDownloadSuccessBlock)success
                 failure:(SLFailureBlock)failure {

    [self invokeStaticMethod:@"download"
                  parameters:@{ @"name": name,
                                @"container": container }
                outputStream:outputStream
                     success:^(id value) {
                         success();
                     }
                     failure:failure];
}

- (void)downloadAsDataWithName:(NSString *)name
                     container:(NSString *)container
                       success:(LBFileDownloadAsDataSuccessBlock)success
                       failure:(SLFailureBlock)failure {

    __block NSOutputStream *outputStream = [[NSOutputStream alloc] initToMemory];

    [self downloadWithName:name
                 container:container
              outputStream:outputStream
                   success:^() {
                       NSData *data =
                        [outputStream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
                       success(data);
                   }
                   failure:^(NSError *err) {
                       [outputStream close];
                       failure(err);
                   }];

}

@end