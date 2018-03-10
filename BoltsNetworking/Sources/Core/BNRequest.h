//
//  BNRequest.h
//  BoltsNetworking
//
//  Created by mainuser on 2/27/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BNHTTPMethod){
    GET, POST, PUT, DELETE, HEAD
};

typedef struct BNRequestParameters {
    NSTimeInterval timeout;
    NSTimeInterval throttleInterval;
    NSUInteger retryAttempts;
} BNRequestParameters;
extern BNRequestParameters BNDefaultParameters(void);

@class BNRequestRetryStrategy;
@protocol BNRequestBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface BNResult<Value>: NSObject
@property (nonatomic, readonly, nullable) Value value;
@property (nonatomic, readonly, nullable) NSError *error;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)value:(Value)value;
+ (instancetype)error:(NSError *)error;

@end

@interface BNRequest<__covariant Response, RawResponse> : NSObject

typedef NSURLRequest *_Nonnull(^BNRequestBuilderBlock)(id<BNRequestBuilder>);
typedef BNResult<Response> *_Nonnull(^BNResponseParser)(RawResponse _Nullable);
typedef void (^ _Nullable BNRequestCompletion)(Response _Nullable, NSError * _Nullable);

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithRequestBuilder:(BNRequestBuilderBlock)requestBuilder
                        responseParser:(BNResponseParser)parser
                            parameters:(BNRequestParameters)parameters
                            completion:(BNRequestCompletion)completion NS_DESIGNATED_INITIALIZER;

- (nullable BNRequestRetryStrategy *)retryStrategy;

- (NSURLRequest *)buildRequestWithBuilder:(id<BNRequestBuilder>)builder;
- (BNResult<Response> *)parseResponse:(RawResponse const)rawResponse;

- (void)callCompletionWithValue:(nullable Response)value error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
