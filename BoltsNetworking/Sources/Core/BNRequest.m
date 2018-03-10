//
//  BNRequest.m
//  BoltsNetworking
//
//  Created by mainuser on 2/27/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "BNRequest.h"
#import "BNRequestRetryStrategy.h"

BNRequestParameters BNDefaultParameters() {
    return (BNRequestParameters){.timeout=30, .throttleInterval=0, .retryAttempts=0};
}

@interface BNRequest ()
@property (nonatomic) BNRequestBuilder requestBuilder;
@property (nonatomic) BNResponseParser responseParser;
@property (nonatomic) BNRequestParameters parameters;
@property (nonatomic) BNRequestCompletion completion;
@property (nonatomic) dispatch_queue_t deliveryQueue;

@end

@implementation BNRequest

+ (instancetype)new {
    return nil;
}

- (instancetype)init {
    return nil;
}

- (instancetype)initWithRequestBuilder:(BNRequestBuilder)requestBuilder
                        responseParser:(BNResponseParser)parser
                            parameters:(BNRequestParameters)parameters
                            completion:(BNRequestCompletion)completion {
    if ((self = [super init])) {
        _requestBuilder = requestBuilder;
        _responseParser = parser;
        _parameters = parameters;
        _completion = completion;
    }
    return self;
}

- (BNRequestRetryStrategy *)retryStrategy {
    return [BNRequestRetryStrategy strategyWithParameters:self.parameters];
}

- (NSURLRequest *)buildRequest {
    return self.requestBuilder();
}

- (BNResult *)parseResponse:(id)rawResponse {
    return self.responseParser(rawResponse);
}

- (void)callCompletionWithValue:(nullable id)value error:(nullable NSError *)error {
    dispatch_queue_t queue;
    if (self.deliveryQueue) {
        queue = self.deliveryQueue;
    } else {
        queue = dispatch_get_main_queue();
    }
    dispatch_async(queue, ^{
        self.completion(value, error);
    });    
}

@end

@implementation BNResult

+ (instancetype)value:(id)value {
    return [[BNResult alloc] initWithValue:value error:nil];
}

+ (instancetype)error:(NSError *)error {
    return [[BNResult alloc] initWithValue:nil error:error];
}

- (instancetype)initWithValue:(id)value error:(NSError *)error {
    if ((self = [super init])) {
        _value = value;
        _error = error;
    }
    return self;
}

@end
