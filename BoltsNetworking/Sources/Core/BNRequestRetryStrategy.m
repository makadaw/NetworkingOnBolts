//
//  BNRequestRetryStrategy.m
//  BoltsNetworking
//
//  Created by mainuser on 3/8/18.
//

#import "BNRequestRetryStrategy.h"

NSTimeInterval const BNRequestDefaultThrottleInterval = 1.0;

@interface BNRequestRetryStrategy()
@property (nonatomic) BNRequestParameters requestParameters;

@end

@implementation BNRequestRetryStrategy

+ (instancetype)strategyWithParameters:(BNRequestParameters)requestParameters {
    if (requestParameters.retryAttempts < 1) {
        return nil;
    }
    return [[self.class alloc] initWithParameters:requestParameters];
}

- (instancetype)initWithParameters:(BNRequestParameters)requestParameters {
    if ((self = [super init])) {
        _requestParameters = requestParameters;
    }
    return self;
}

- (BOOL)needsToRetry {
    return NO;
}

- (void)countAttempt {
    
}


@end
