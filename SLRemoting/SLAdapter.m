/**
 * @file SLAdapter.m
 *
 * @author Michael Schoonmaker
 * @copyright (c) 2013 StrongLoop. All rights reserved.
 */

#import "SLAdapter.h"

NSString *SLAdapterNotConnectedErrorDescription = @"Adapter not connected.";

@interface SLAdapter()

@property (readwrite, nonatomic) BOOL connected;
@property (readwrite, nonatomic) BOOL allowsInvalidSSLCertificate;

@end

@implementation SLAdapter

+ (instancetype)adapter {
    return [self adapterWithURL:nil];
}

+ (instancetype)adapterWithURL:(NSURL *)url {
    return [self adapterWithURL:url allowsInvalidSSLCertificate:NO];
}

+ (instancetype)adapterWithURL:(NSURL *)url allowsInvalidSSLCertificate : (BOOL) allowsInvalidSSLCertificate {
    return [[self alloc] initWithURL:url allowsInvalidSSLCertificate:allowsInvalidSSLCertificate];
}

- (instancetype)init {
    return [self initWithURL:nil];
}

- (instancetype)initWithURL:(NSURL *)url {
    return [self initWithURL:url allowsInvalidSSLCertificate:NO];
}

- (instancetype)initWithURL:(NSURL *)url  allowsInvalidSSLCertificate : (BOOL) allowsInvalidSSLCertificate {
    self = [super init];
    
    if (self) {
        self.allowsInvalidSSLCertificate = allowsInvalidSSLCertificate;
        self.connected = NO;
        
        if(url) {
            [self connectToURL:url];
        }
    }
    
    return self;
}

- (void)connectToURL:(NSURL *)url {
    // TODO(schoon) - Break out and document error description.
    NSAssert(NO, @"Invalid Adapter.");
}

- (void)invokeStaticMethod:(NSString *)path
                parameters:(NSDictionary *)parameters
            bodyParameters:(NSDictionary *)bodyParameters
              outputStream:(NSOutputStream *)outputStream
                   success:(SLSuccessBlock)success
                   failure:(SLFailureBlock)failure {
    NSAssert(NO, @"Invalid Adapter.");
}

- (void)invokeInstanceMethod:(NSString *)method
       constructorParameters:(NSDictionary *)constructorParameters
                  parameters:(NSDictionary *)parameters
              bodyParameters:(NSDictionary *)bodyParameters
                outputStream:(NSOutputStream *)outputStream
                     success:(SLSuccessBlock)success
                     failure:(SLFailureBlock)failure {
    NSAssert(NO, @"Invalid Adapter.");
}

@end
