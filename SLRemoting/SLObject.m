/**
 * @file SLObject.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLObject.h"

@interface SLObject()

@property (readwrite, nonatomic, weak) SLRepository *repository;
@property (readwrite, nonatomic, strong) NSDictionary *creationParameters;

@end

@interface SLRepository()

@property (readwrite, nonatomic, copy) NSString *className;

@end

@implementation SLObject

NSString *SLObjectInvalidRepositoryDescription = @"Invalid repository.";

+ (instancetype)objectWithRepository:(SLRepository *)repository
                         parameters:(NSDictionary *)parameters {
    return [[self alloc] initWithRepository:repository parameters:parameters];
}

- (instancetype)initWithRepository:(SLRepository *)repository
                       parameters:(NSDictionary *)parameters {
    self = [super init];

    if (self) {
        self.repository = repository;
        self.creationParameters = parameters;
    }

    return self;
}

- (void)invokeMethod:(NSString *)name
          parameters:(NSDictionary *)parameters
             success:(SLSuccessBlock)success
             failure:(SLFailureBlock)failure {
    NSAssert(self.repository, SLObjectInvalidRepositoryDescription);

    NSString *path = [NSString stringWithFormat:@"%@.prototype.%@",
                      self.repository.className,
                      name];

    [self.repository.adapter invokeInstanceMethod:path
                            constructorParameters:self.creationParameters
                                       parameters:parameters
                                   bodyParameters:nil
                                     outputStream:nil
                                          success:success
                                          failure:failure];
}

- (void)invokeMethod:(NSString *)name
          parameters:(NSDictionary *)parameters
      bodyParameters:(NSDictionary *)bodyParameters
             success:(SLSuccessBlock)success
             failure:(SLFailureBlock)failure {
    NSAssert(self.repository, SLObjectInvalidRepositoryDescription);

    NSString *path = [NSString stringWithFormat:@"%@.prototype.%@",
                      self.repository.className,
                      name];

    [self.repository.adapter invokeInstanceMethod:path
                            constructorParameters:self.creationParameters
                                       parameters:parameters
                                   bodyParameters:bodyParameters
                                     outputStream:nil
                                          success:success
                                          failure:failure];
}

- (void)invokeMethod:(NSString *)name
          parameters:(NSDictionary *)parameters
        outputStream:(NSOutputStream *)outputStream
             success:(SLSuccessBlock)success
             failure:(SLFailureBlock)failure {

    NSAssert(self.repository, SLObjectInvalidRepositoryDescription);

    NSString *path = [NSString stringWithFormat:@"%@.prototype.%@",
                      self.repository.className,
                      name];

    [self.repository.adapter invokeInstanceMethod:path
                            constructorParameters:self.creationParameters
                                       parameters:parameters
                                   bodyParameters:nil
                                     outputStream:outputStream
                                          success:success
                                          failure:failure];
}

@end

@implementation SLRepository

+ (instancetype)repositoryWithClassName:(NSString *)name {
    return [[self alloc] initWithClassName:name];
}

- (instancetype)initWithClassName:(NSString *)name {
    self = [super init];

    if (self) {
        self.className = name;
    }

    return self;
}

- (SLObject *)objectWithParameters:(NSDictionary *)parameters {
    return [SLObject objectWithRepository:self parameters:parameters];
}

- (void)invokeStaticMethod:(NSString *)name
                parameters:(NSDictionary *)parameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {

    NSString *path = [NSString stringWithFormat:@"%@.%@", self.className, name];
    [self.adapter invokeStaticMethod:path
                          parameters:parameters
                      bodyParameters:nil
                        outputStream:nil
                             success:success
                             failure:failure];
}

- (void)invokeStaticMethod:(NSString *)name
                parameters:(NSDictionary *)parameters
            bodyParameters:(NSDictionary *)bodyParameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {

    NSString *path = [NSString stringWithFormat:@"%@.%@", self.className, name];
    [self.adapter invokeStaticMethod:path
                          parameters:parameters
                      bodyParameters:bodyParameters
                        outputStream:nil
                             success:success
                             failure:failure];
}

- (void)invokeStaticMethod:(NSString *)name
                parameters:(NSDictionary *)parameters
              outputStream:(NSOutputStream *)outputStream
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {

    NSString *path = [NSString stringWithFormat:@"%@.%@", self.className, name];
    [self.adapter invokeStaticMethod:path
                          parameters:parameters
                      bodyParameters:nil
                        outputStream:outputStream
                             success:success
                             failure:failure];
}

@end
