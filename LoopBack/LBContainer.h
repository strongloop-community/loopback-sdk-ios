/**
 * @file LBContainer.h
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBModel.h"
#import "LBFile.h"

@class LBFileRepository;

/**
 * A local representative of a container instance on the server.
 */
@interface LBContainer : LBModel

@property (nonatomic, copy) NSString *name;

/**
 * Blocks of this type are executed when
 * LBContainer:uploadWithSuccess:failure: is successful.
 */
typedef void (^LBContainerDeleteSuccessBlock)();
/**
 * Deletes the container on the server.
 *
 * @param success  The block to be executed when the delete is successful.
 * @param failure  The block to be executed when the delete fails.
 */
- (void)deleteWithSuccess:(LBContainerDeleteSuccessBlock)success
                  failure:(SLFailureBlock)failure;

/**
 * Gets the file with the given name.
 *
 * @param  name       The file name.
 * @param  localPath  The local path to the file, without file name.
 * @param  success    The block to be executed when the get is successful.
 * @param  failure    The block to be executed when the get fails.
 */
- (void)getFileWithName:(NSString*)name
              localPath:(NSString*)localPath
                success:(LBFileGetSuccessBlock)success
                failure:(SLFailureBlock)failure;

@end

/**
 * A local representative of the Container type on the server.
 */
@interface LBContainerRepository : LBModelRepository

/** Model repository for this container. */
@property (nonatomic, readonly, strong) LBFileRepository *fileRepository;

+ (instancetype)repository;

/**
 * Creates a container with the given name.
 *
 * @param  name       The container name.
 */
- (LBContainer *)createContainerWithName:(NSString*)name;

/**
 * Blocks of this type are executed when
 * LBContainerRepository::getContainerWithName:success:failure: is successful.
 */
typedef void (^LBGetContainerSuccessBlock)(LBContainer* container);
/**
 * Attempts to get the named container from the server.
 *
 * @param name     The container name.
 * @param success  The block to be executed when the get is successful.
 * @param failure  The block to be executed when the get fails.
 */
- (void)getContainerWithName:(NSString*)name
                     success:(LBGetContainerSuccessBlock)success
                     failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBContainerRepository::getAllContainersWithSuccess:failure: is successful.
 */
typedef void (^LBGetAllContainersSuccessBlock)(NSArray* containers);
/**
 * Returns all containers on the server.
 *
 * @param success  The block to be executed when the get is successful.
 * @param failure  The block to be executed when the get fails.
 */
- (void)getAllContainersWithSuccess:(LBGetAllContainersSuccessBlock)success
                            failure:(SLFailureBlock)failure;

@end