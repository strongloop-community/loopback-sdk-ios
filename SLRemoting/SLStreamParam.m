/**
 * @file SLStreamParam.m
 *
 * @copyright (c) 2015 StrongLoop. All rights reserved.
 */

#import "SLStreamParam.h"

@interface SLStreamParam()

@property (readwrite, nonatomic, strong) NSInputStream *inputStream;
@property (readwrite, nonatomic, copy) NSString *fileName;
@property (readwrite, nonatomic, copy) NSString *contentType;
@property (readwrite, nonatomic, assign) NSInteger length;

@end

@implementation SLStreamParam

+ (instancetype)streamParamWithInputStream:(NSInputStream *)inputStream
                                  fileName:(NSString *)fileName
                               contentType:(NSString *)contentType
                                    length:(NSInteger)length {

    SLStreamParam *param = [[self alloc] init];
    param.inputStream = inputStream;
    param.fileName = fileName;
    param.contentType = contentType;
    param.length = length;

    return param;
}

@end
