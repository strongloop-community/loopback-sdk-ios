/**
 * @file LBFile.m
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBFile.h"
#import "LBRESTAdapter.h"

@implementation LBFile

- (void)uploadWithSuccess:(LBFileUploadSuccessBlock)success
                  failure:(SLFailureBlock)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", _url, _name]]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               self.fileData = data;
                               if (error != nil)
                                   failure(error);
                               else {
                                   [self invokeMethod:@"upload"
                                        parameters:[self toDictionary]
                                           success:^(id value) {
                                               success();
                                           }
                                           failure:failure];
                               }
                              }];
}

- (void)downloadWithSuccess:(LBFileUploadSuccessBlock)success
                    failure:(SLFailureBlock)failure {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", _url, _name]]];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               self.fileData = data;
                               if (error != nil)
                                   failure(error);
                               else {
                                   [self invokeMethod:@"download"
                                           parameters:[self toDictionary]
                                              success:^(id value) {
                                                  success();
                                              }
                                              failure:failure];
                               }
                           }];
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
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/download", self.className]
                                                     verb:@"GET"
                                                multipart:YES]
            forMethod:[NSString stringWithFormat:@"%@.prototype.download", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:container/files/:name", self.className]
                                                     verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.get", self.className]];
    
    return contract;
}

- (LBFile *)createFileWithName:(NSString*)name
                           url:(NSString*)url
                     container:(NSString*)container {
    LBFile *file = (LBFile*)[self modelWithDictionary:@{@"name" : name, @"url" : url, @"container" : container}];
    return file;
}

- (void)getFileWithName:(NSString*)name
              container:(NSString*)container
                success:(LBFileGetSuccessBlock)success
                failure:(SLFailureBlock)failure {
    NSParameterAssert(name);
    NSParameterAssert(container);
    [self invokeStaticMethod:@"get"
            parameters:@{@"name": name, @"container" : container}
               success:^(id value) {
                   NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                   success((LBFile*)[self modelWithDictionary:value]);
               } failure:failure];
}

@end