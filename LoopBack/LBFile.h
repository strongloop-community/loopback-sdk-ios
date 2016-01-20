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
typedef void (^LBFileUploadSuccessBlock)(LBFile *file);
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

/**
 * Blocks of this type are executed when
 * LBFile:deleteWithSuccess:failure: is successful.
 */
typedef void (^LBFileDeleteSuccessBlock)();
/**
 * Delete the file from the server.
 *
 * @param success  The block to be executed when the deletion is successful.
 * @param failure  The block to be executed when the deletion fails.
 */
- (void)deleteWithSuccess:(LBFileDeleteSuccessBlock)success
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
- (LBFile *)createFileWithName:(NSString *)name
                     localPath:(NSString *)localPath
                     container:(NSString *)container;

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
- (void)getFileWithName:(NSString *)name
              localPath:(NSString *)localPath
              container:(NSString *)container
                success:(LBFileGetSuccessBlock)success
                failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBFileRepository::getAllFilesWithContainer:success:failure: is successful.
 */
typedef void (^LBGetAllFilesSuccessBlock)(NSArray* files);

/**
 * List all files in the specified container.
 *
 * @param  container    The target container.
 * @param  success      The block to be executed when the get is successful.
 * @param  failure      The block to be executed when the get fails.
 */
- (void)getAllFilesWithContainer:(NSString *)container
                         success:(LBGetAllFilesSuccessBlock)success
                         failure:(SLFailureBlock)failure;
/**
 * Upload a new file from the given input stream.
 *
 * @param  name         The file name, must be unique within the container.
 * @param  container    The file's container.
 * @param  inputStream  The input stream from which the content of file is read.
 * @param  contentType  The content type of the file.
 * @param  success      The block to be executed when the get is successful.
 * @param  failure      The block to be executed when the get fails.
 */
- (void)uploadWithName:(NSString *)name
             container:(NSString *)container
           inputStream:(NSInputStream *)inputStream
           contentType:(NSString *)contentType
                length:(NSInteger)length
               success:(LBFileUploadSuccessBlock)success
               failure:(SLFailureBlock)failure;

/**
 * Upload a new file from the given binary data.
 *
 * @param  name         The file name, must be unique within the container.
 * @param  container    The file's container.
 * @param  data         The data from which the content of file is read.
 * @param  contentType  The content type of the file.
 * @param  success      The block to be executed when the get is successful.
 * @param  failure      The block to be executed when the get fails.
 */
- (void)uploadWithName:(NSString *)name
             container:(NSString *)container
                  data:(NSData *)data
           contentType:(NSString *)contentType
               success:(LBFileUploadSuccessBlock)success
               failure:(SLFailureBlock)failure;

/**
 * Download content of specified file using the specified output stream.
 *
 * @param  name         The file name.
 * @param  container    The file's container.
 * @param  outputStream The output stream to which the content of file is written.
 * @param  success      The block to be executed when the get is successful.
 * @param  failure      The block to be executed when the get fails.
 */
- (void)downloadWithName:(NSString *)name
               container:(NSString *)container
            outputStream:(NSOutputStream *)outputStream
                 success:(LBFileDownloadSuccessBlock)success
                 failure:(SLFailureBlock)failure;

/**
 * Blocks of this type are executed when
 * LBFileRepository::downloadAsDataWithName:container:success:failure: is successful.
 */
typedef void (^LBFileDownloadAsDataSuccessBlock)(NSData *data);
/**
 * Download content of specified file as a binray data.
 *
 * @param  name         The file name.
 * @param  container    The file's container.
 * @param  success      The block to be executed when the get is successful.
 * @param  failure      The block to be executed when the get fails.
 */
- (void)downloadAsDataWithName:(NSString *)name
                     container:(NSString *)container
                       success:(LBFileDownloadAsDataSuccessBlock)success
                       failure:(SLFailureBlock)failure;

@end