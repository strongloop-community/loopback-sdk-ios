/**
 * @file SLRESTAdapter.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLRESTAdapter.h"
#import "SLStreamParam.h"

#import "SLAFHTTPClient.h"
#import "SLAFJSONRequestOperation.h"

static NSString * const DEFAULT_DEV_BASE_URL = @"http://localhost:3001";

@interface SLRESTAdapter() {
    SLAFHTTPClient *client;
}

@property (readwrite, nonatomic) BOOL connected;

- (void)requestWithPath:(NSString *)path
                   verb:(NSString *)verb
             parameters:(NSDictionary *)parameters
              multipart:(BOOL)multipart
           outputStream:(NSOutputStream *)outputStream
                success:(SLSuccessBlock)success
                failure:(SLFailureBlock)failure;

- (void)appendPartToMultiPartForm:(id <AFMultipartFormData>)formData
                   withParameters:(NSDictionary *)parameters;

@end

@implementation SLRESTAdapter

@synthesize connected;

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

    [self invokeStaticMethod:method
                  parameters:parameters
                outputStream:nil
                     success:success
                     failure:failure];
}

- (void)invokeStaticMethod:(NSString *)method
                parameters:(NSDictionary *)parameters
              outputStream:(NSOutputStream *)outputStream
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {
    
    NSAssert(self.contract, @"Invalid contract.");

    NSString *verb = [self.contract verbForMethod:method];
    NSString *path = [self.contract urlForMethod:method parameters:parameters];
    BOOL multipart = [self.contract multipartForMethod:method];

    [self requestWithPath:path
                     verb:verb
               parameters:parameters
                multipart:multipart
             outputStream:outputStream
                  success:success
                  failure:failure];
}

- (void)invokeInstanceMethod:(NSString *)method
       constructorParameters:(NSDictionary *)constructorParameters
                  parameters:(NSDictionary *)parameters
                     success:(SLSuccessBlock)success
                     failure:(SLFailureBlock)failure {

    [self invokeInstanceMethod:method
         constructorParameters:constructorParameters
                    parameters:parameters
                  outputStream:nil
                       success:success
                       failure:failure];
}

- (void)invokeInstanceMethod:(NSString *)method
       constructorParameters:(NSDictionary *)constructorParameters
                  parameters:(NSDictionary *)parameters
                outputStream:(NSOutputStream *)outputStream
                     success:(SLSuccessBlock)success
                     failure:(SLFailureBlock)failure {
    // TODO(schoon) - Break out and document error description.
    NSAssert(self.contract, @"Invalid contract.");

    NSMutableDictionary *combinedParameters = [NSMutableDictionary dictionary];
    [combinedParameters addEntriesFromDictionary:constructorParameters];
    [combinedParameters addEntriesFromDictionary:parameters];

    NSString *verb = [self.contract verbForMethod:method];
    NSString *path = [self.contract urlForMethod:method parameters:combinedParameters];
    BOOL multipart = [self.contract multipartForMethod:method];

    [self requestWithPath:path
                     verb:verb
               parameters:combinedParameters
                multipart:multipart
             outputStream:outputStream
                  success:success
                  failure:failure];
}

- (void)requestWithPath:(NSString *)path
                   verb:(NSString *)verb
             parameters:(NSDictionary *)parameters
              multipart:(BOOL)multipart
           outputStream:(NSOutputStream *)outputStream
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

    NSURLRequest *request;

    if (!multipart) {
        request = [client requestWithMethod:verb path:path parameters:parameters];
    } else {
        request = [client multipartFormRequestWithMethod:verb
                                                    path:path
                                              parameters:parameters
                               constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                   [self appendPartToMultiPartForm:formData
                                                    withParameters:parameters];
                               }];
    }

    SLAFHTTPRequestOperation *operation;
    // Synchronize the block so that the invocations of client's [un]registerHTTPOperationClass:
    // and HTTPRequestOperationWithRequest:success: methods become atomic.
    @synchronized(self) {
        if (outputStream != nil) {
            // The following is needed to force the received binary payload always go to the stream
            [client unregisterHTTPOperationClass:[SLAFJSONRequestOperation class]];
        }

        operation = [client HTTPRequestOperationWithRequest:request
                                                    success:^(SLAFHTTPRequestOperation *operation,
                                                              id responseObject) {
            success(responseObject);
        } failure:^(SLAFHTTPRequestOperation *operation, NSError *error) {
            failure(error);
        }];

        if (outputStream != nil) {
            // Re-register the response handler class
            [client registerHTTPOperationClass:[SLAFJSONRequestOperation class]];
            
            operation.outputStream = outputStream;
        }
    }

    [client enqueueHTTPRequestOperation:operation];
}

- (void)appendPartToMultiPartForm:(id <AFMultipartFormData>)formData
                   withParameters:(NSDictionary *)parameters {
    for (id key in parameters) {
        id value = parameters[key];

        if ([value isKindOfClass:[SLStreamParam class]]) {
            SLStreamParam *streamParam = (SLStreamParam *)value;
            [formData appendPartWithInputStream:streamParam.inputStream
                                           name:key
                                       fileName:streamParam.fileName
                                         length:streamParam.length
                                       mimeType:streamParam.contentType];
        } else {
            NSLog(@"%s: Ignored non SLStreamParam parameter %@ specified for multipart form",
                  __FUNCTION__, [value class]);
        }
    }
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
