/**
 * @file LBContainer.m
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBContainer.h"
#import "LBFile.h"
#import "LBRESTAdapter.h"

@implementation LBContainer

- (void)deleteWithSuccess:(LBContainerDeleteSuccessBlock)success
                  failure:(SLFailureBlock)failure {
    [self invokeMethod:@"remove"
            parameters:[self toDictionary]
               success:^(id value) {
                   success();
               }
               failure:failure];
}

- (void)getFileWithName:(NSString*)name
              localPath:(NSString*)localPath
                success:(LBFileGetSuccessBlock)success
                failure:(SLFailureBlock)failure {
    LBContainerRepository* containerRepo = (LBContainerRepository*)[self repository];
    [containerRepo.fileRepository getFileWithName:name
                                        localPath:localPath
                                        container:self.name
                                          success:success
                                          failure:failure];
}

@end

@interface LBContainerRepository ()

@property (nonatomic, readwrite, strong) LBFileRepository *fileRepository;

@end

@implementation LBContainerRepository

+ (instancetype)repository {
    LBContainerRepository *repository = [self repositoryWithClassName:@"containers"];
    return repository;
}

- (SLRESTContract *)contract {
    SLRESTContract *contract = [super contract];

    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@", self.className]
                                                     verb:@"POST"]
            forMethod:[NSString stringWithFormat:@"%@.create", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@", self.className]
                                                     verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.getAll", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:name", self.className]
                                                     verb:@"GET"]
            forMethod:[NSString stringWithFormat:@"%@.get", self.className]];
    [contract addItem:[SLRESTContractItem itemWithPattern:[NSString stringWithFormat:@"/%@/:name", self.className]
                                                     verb:@"DELETE"]
            forMethod:[NSString stringWithFormat:@"%@.prototype.remove", self.className]];
    
    return contract;
}

- (LBFileRepository *)fileRepository {
    if (_fileRepository == nil) {
        LBRESTAdapter* adapter = (LBRESTAdapter*)self.adapter;
        self.fileRepository = (LBFileRepository *)[adapter repositoryWithClass:[LBFileRepository class]];
    }
    return _fileRepository;
}

- (void)createContainerWithName:(NSString*)name
                        success:(LBContainerCreateSuccessBlock)success
                        failure:(SLFailureBlock)failure {
    NSParameterAssert(name);
    [self invokeStaticMethod:@"create"
                  parameters:nil
              bodyParameters:@{@"name": name}
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         LBContainer *container = (LBContainer*)[self modelWithDictionary:(NSDictionary*)value];
                         success(container);
                     } failure:failure];
}

- (void)getContainerWithName:(NSString*)name
                     success:(LBContainerGetSuccessBlock)success
                     failure:(SLFailureBlock)failure {
    NSParameterAssert(name);
    [self invokeStaticMethod:@"get"
                  parameters:@{@"name": name}
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", value);
                         LBContainer *container = (LBContainer*)[self modelWithDictionary:(NSDictionary*)value];
                         success(container);
                     } failure:failure];
}

- (void)getAllContainersWithSuccess:(LBContainerGetAllSuccessBlock)success
                            failure:(SLFailureBlock)failure {
    [self invokeStaticMethod:@"getAll"
                  parameters:nil
                     success:^(id value) {
                         NSAssert([[value class] isSubclassOfClass:[NSArray class]], @"Received non-Array: %@", value);
                         NSArray* response = (NSArray*)value;
                         NSMutableArray *containers = [NSMutableArray arrayWithCapacity:response.count];
                         for (id respVal in response) {
                             NSAssert([[respVal class] isSubclassOfClass:[NSDictionary class]], @"Received non-Dictionary: %@", respVal);
                             LBContainer *container = (LBContainer*)[self modelWithDictionary:(NSDictionary*)respVal];
                             [containers addObject:container];
                         }
                         success(containers);
                     } failure:failure];
}

@end