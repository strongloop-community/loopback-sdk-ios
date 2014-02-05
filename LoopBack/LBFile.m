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
    
    return contract;
}

- (LBFile *)createFileWithName:(NSString*)name
                           url:(NSString*)url
                     container:(NSString*)container {
    LBFile *file = (LBFile*)[self modelWithDictionary:@{@"name" : name, @"url" : url, @"container" : container}];
    return file;
}

@end