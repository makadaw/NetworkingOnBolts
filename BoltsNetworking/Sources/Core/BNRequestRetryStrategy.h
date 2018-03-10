//
//  BNRequestRetryStrategy.h
//  BoltsNetworking
//
//  Created by mainuser on 3/8/18.
//

#import "BNRequest.h"
#import <Foundation/Foundation.h>

extern NSTimeInterval const BNRequestDefaultThrottleInterval;

@interface BNRequestRetryStrategy : NSObject
@property (nonatomic, readonly) NSTimeInterval delay;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)strategyWithParameters:(BNRequestParameters)requestParameters;

- (BOOL)needsToRetry;
- (void)countAttempt;

@end
