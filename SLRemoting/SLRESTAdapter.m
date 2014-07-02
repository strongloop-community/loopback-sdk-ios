/**
 * @file SLRESTAdapter.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLRESTAdapter.h"

#import "SLAFHTTPClient.h"
#import "SLAFJSONRequestOperation.h"

static NSString * const DEFAULT_DEV_BASE_URL = @"http://localhost:3001";

@interface SLRESTAdapter() {
    SLAFHTTPClient *client;
}

@property (readwrite, nonatomic) BOOL connected;

- (void)requestPath:(NSString *)path
               verb:(NSString *)verb
         parameters:(NSDictionary *)parameters
            success:(SLSuccessBlock)success
            failure:(SLFailureBlock)failure;

- (void)requestMultipartPath:(NSString *)path
                        verb:(NSString *)verb
                    fileName:(NSString *)fileName
                    localURL:(NSString *)localURL
                     success:(SLSuccessBlock)success
                     failure:(SLFailureBlock)failure;

@end

@implementation SLRESTAdapter

- (instancetype)initWithURL:(NSURL *)url allowsInvalidSSLCertificate : (BOOL) allowsInvalidSSLCertificate {
    self = [super initWithURL:url allowsInvalidSSLCertificate:allowsInvalidSSLCertificate];

    if (self) {
        self.contract = [SLRESTContract contract];
    }

    return self;
}

- (void)connectToURL:(NSURL *)url {
    // Ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected
    if ([[url path] length] > 0 && ![[url absoluteString] hasSuffix:@"/"]) {
        url = [url URLByAppendingPathComponent:@"/"];
    }

    client = [SLAFHTTPClient clientWithBaseURL:url];
    client.allowsInvalidSSLCertificate = self.allowsInvalidSSLCertificate;

    self.connected = YES;

    client.parameterEncoding = AFJSONParameterEncoding;
    [client registerHTTPOperationClass:[SLAFJSONRequestOperation class]];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
}

- (void)invokeStaticMethod:(NSString *)method
                parameters:(NSDictionary *)parameters
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {
    NSAssert(self.contract, @"Invalid contract.");

    NSString *verb = [self.contract verbForMethod:method];
    NSString *path = [self.contract urlForMethod:method parameters:parameters];

    [self requestPath:path
                 verb:verb
           parameters:parameters
              success:success
              failure:failure];
}

- (void)invokeInstanceMethod:(NSString *)method
       constructorParameters:(NSDictionary *)constructorParameters
                  parameters:(NSDictionary *)parameters
                     success:(SLSuccessBlock)success
                     failure:(SLFailureBlock)failure {
    // TODO(schoon) - Break out and document error description.
    NSAssert(self.contract, @"Invalid contract.");

    NSMutableDictionary *combinedParameters = [NSMutableDictionary dictionary];
    [combinedParameters addEntriesFromDictionary:constructorParameters];
    [combinedParameters addEntriesFromDictionary:parameters];

    NSString *verb = [self.contract verbForMethod:method];
    NSString *path = [self.contract urlForMethod:method parameters:combinedParameters];

    if ([self.contract multipartForMethod:method]) {
        [self requestMultipartPath:path
                              verb:verb
                          fileName:parameters[@"name"]
                          localURL:parameters[@"localPath"]
                           success:success
                           failure:failure];
    } else {
        [self requestPath:path
                     verb:verb
               parameters:combinedParameters
                  success:success
                  failure:failure];
    }
}

- (void)requestPath:(NSString *)path
               verb:(NSString *)verb
         parameters:(NSDictionary *)parameters
            success:(SLSuccessBlock)success
            failure:(SLFailureBlock)failure {
    NSAssert(self.connected, SLAdapterNotConnectedErrorDescription);

    if ([[verb uppercaseString] isEqualToString:@"GET"]) {
        client.parameterEncoding = AFFormURLParameterEncoding;
    } else {
        client.parameterEncoding = AFJSONParameterEncoding;
    }

    // Remove the leading / so that the path is treated as relative to the baseURL
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    
	NSURLRequest *request = [client requestWithMethod:verb path:path parameters:parameters];
    SLAFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(SLAFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(SLAFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    [client enqueueHTTPRequestOperation:operation];
}

- (void)requestMultipartPath:(NSString *)path
                        verb:(NSString *)verb
                    fileName:(NSString *)fileName
                    localURL:(NSString *)localURL
                     success:(SLSuccessBlock)success
                     failure:(SLFailureBlock)failure {
    NSAssert(self.connected, SLAdapterNotConnectedErrorDescription);
    
    // Remove the leading / so that the path is treated as relative to the baseURL
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    
    NSURLRequest *request;
    NSOutputStream *outStream = nil;
    if ([[verb uppercaseString] isEqualToString:@"GET"]) {
        path = [path stringByAppendingPathComponent:fileName];
        
        request = [client requestWithMethod:verb path:path parameters:nil];
        outStream = [NSOutputStream outputStreamToFileAtPath:[localURL stringByAppendingPathComponent:fileName] append:NO];
    } else {
        request = [client multipartFormRequestWithMethod:verb path:path parameters:nil constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
            NSString* fullLocalPath = [localURL stringByAppendingPathComponent:fileName];
            NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fullLocalPath error:NULL];
            [formData appendPartWithInputStream:[[NSInputStream alloc] initWithFileAtPath:fullLocalPath]
                                           name:@"uploadfiles"
                                       fileName:fileName
                                         length:attributes.fileSize
                                       mimeType:@"multipart/form-data"];
        }];
    }
    
    SLAFHTTPRequestOperation *operation = [client HTTPRequestOperationWithRequest:request success:^(SLAFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(SLAFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
    if (outStream != nil) {
        operation.outputStream = outStream;
    }
    
    [client enqueueHTTPRequestOperation:operation];
}

- (NSString*)accessToken
{
    return [client defaultValueForHeader:@"Authorization"];
}

- (void)setAccessToken:(NSString *)accessToken
{
    [client setDefaultHeader:@"Authorization" value:accessToken];
}

@end
