/**
 * @file SLStreamParam.h
 *
 * @copyright (c) 2015 StrongLoop. All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * A request parameter that is a (binary) stream.
 */
@interface SLStreamParam : NSObject

@property (readonly, nonatomic, strong) NSInputStream *inputStream;
@property (readonly, nonatomic, copy) NSString *fileName;
@property (readonly, nonatomic, copy) NSString *contentType;
@property (readonly, nonatomic, assign) NSInteger length;

+ (instancetype)streamParamWithInputStream:(NSInputStream *)inputStream
                                  fileName:(NSString *)fileName
                               contentType:(NSString *)contentType
                                    length:(NSInteger)length;

@end
