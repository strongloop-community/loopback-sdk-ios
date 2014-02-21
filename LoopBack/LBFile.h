/**
 * @file LBFile.h
 *
 * @author Stephen Hess
 * @copyright (c) 2014 StrongLoop. All rights reserved.
 */

#import "LBModel.h"

/**
 * A local representative of a file instance on the server.
 */
@interface LBFile : LBModel

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *localPath;

@property (nonatomic, copy) NSString *container;

/**
 * Blocks of this type are executed when
 * LBFile:uploadWithSuccess:failure: is successful.
 */
typedef void (^LBFileUploadSuccessBlock)();
/**
 * Uploads the file to the server.
 *
 * @param success  The block to be executed when the upload is successful.
 * @param failure  The block to be executed when the upload fails.
 */
- (void)uploadWithSuccess:(LBFileUploadSuccessBlock)success
                  failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBFile:downloadWithSuccess:failure: is successful.
 */
typedef void (^LBFileDownloadSuccessBlock)();
/**
 * Downloads the file from the server.
 *
 * @param success  The block to be executed when the download is successful.
 * @param failure  The block to be executed when the download fails.
 */
- (void)downloadWithSuccess:(LBFileDownloadSuccessBlock)success
                    failure:(SLFailureBlock)failure;

@end

/**
 * A local representative of the File type on the server.
 */
@interface LBFileRepository : LBModelRepository

+ (instancetype)repository;

/**
 * Creates a file with the given data
 *
 * @param  name       The file name.
 * @param  localPath  The local path to the file, without file name.
 * @param  container  The file's container.
 */
- (LBFile *)createFileWithName:(NSString*)name
                     localPath:(NSString*)localPath
                     container:(NSString*)container;

/**
 * Blocks of this type are executed when
 * LBFileRepository::getFileWithName:success:failure: is successful.
 */
typedef void (^LBFileGetSuccessBlock)(LBFile* file);
/**
 * Gets the file with the given name.
 *
 * @param  name       The file name.
 * @param  localPath  The local path to the file, without file name.
 * @param  container  The file's container.
 * @param  success    The block to be executed when the get is successful.
 * @param  failure    The block to be executed when the get fails.
 */
- (void)getFileWithName:(NSString*)name
              localPath:(NSString*)localPath
              container:(NSString*)container
                success:(LBFileGetSuccessBlock)success
                failure:(SLFailureBlock)failure;
@end