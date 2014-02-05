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
@property (nonatomic, copy) NSString *url;

@property (nonatomic, copy) NSString *container;
@property (nonatomic, strong) NSData *fileData;

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
- (void)downloadWithSuccess:(LBFileUploadSuccessBlock)success
                    failure:(SLFailureBlock)failure;

@end

/**
 * A local representative of the User type on the server, encapsulating
 * all User properties.
 */
@interface LBFileRepository : LBModelRepository

+ (instancetype)repository;

/**
 * Creates a file with the given data
 *
 * @param  name       The file name.
 * @param  url        The file url.
 * @param  container  The file's container.
 */
- (LBFile *)createFileWithName:(NSString*)name
                           url:(NSString*)url
                     container:(NSString*)container;
@end