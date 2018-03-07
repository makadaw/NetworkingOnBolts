//
//  BNRequestRunner.m
//  BoltsNetworking
//
//  Created by mainuser on 2/27/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "BNRequestRunner.h"
#import <Bolts/BFTask.h>
#import <Bolts/BFTaskCompletionSource.h>
#import <Bolts/BFCancellationToken.h>
#import <Bolts/BFExecutor.h>
#import "BNNetworkConnector.h"
#import "BNRequest.h"

NSTimeInterval const BNRequestRunnerDefaultRequestThrottleInterval = 1.0;

@interface BNRequestRunner ()
@property (nonatomic) id<BNNetworkConnector> connector;
@property (nonatomic) dispatch_queue_t workerQueue;
@property (assign) NSTimeInterval requestThrottleInterval;

@end

@implementation BNRequestRunner

- (instancetype)initWithConnector:(id<BNNetworkConnector>)connector {
    return [self initWithConnector:connector requestThrottleInterval:BNRequestRunnerDefaultRequestThrottleInterval];
}

- (instancetype)initWithConnector:(id<BNNetworkConnector>)connector requestThrottleInterval:(NSTimeInterval)requestThrottleInterval {
    if ((self = [super init])) {
        _connector = connector;
        _workerQueue = dispatch_queue_create("bolts.networking.runner", DISPATCH_QUEUE_CONCURRENT);
        _requestThrottleInterval = requestThrottleInterval;
    }
    return self;
}

- (BFTask<__kindof id> *)runRequestAsync:(BNRequest *)request cancellationToken:(nullable BFCancellationToken *)cancellationToken {
    __weak typeof(self) wSelf = self;
    
    return [[self performRequestRunningBlock:^id{
        typeof(self) sSelf = wSelf;
        return [[sSelf buildURLRequestFromRequest:request] continueWithBlock:^id(BFTask<NSURLRequest *> *task) {
            return [sSelf.connector performDataURLRequest:task.result forRequest:request cancellationToken:cancellationToken];
        }];
    } requestParameters:request.parameters cancellationToken:cancellationToken]
            continueWithBlock:^id _Nullable(BFTask *task) {
        
                // If there are some errors in request just return task back
                if (task.error) {
                    [request callCompletionWithValue:nil error:task.error];
                    return task;
                }
                // Now we can actually parse our response and call completion
                BNResult *result = [request parseResponse:task.result];
                [request callCompletionWithValue:result.value error:result.error];
                if (result.error) {
                    return [BFTask taskWithError:result.error];
                } else {
                    return [BFTask taskWithResult:result.value];
                }
            } cancellationToken:cancellationToken];
}

- (BFTask<NSURL *> *)runFileDownloadRequest:(BNRequest *)request
                          cancellationToken:(nullable BFCancellationToken *)cancellationToken
                              progressBlock:(nullable BNProgressBlock)progressBlock {
    return nil; //TODO implement
}

#pragma mark - Request builder

- (BFTask<NSURLRequest *> *)buildURLRequestFromRequest:(BNRequest *)request {
    return [BFTask taskFromExecutor:[BFExecutor executorWithDispatchQueue:self.workerQueue] withBlock:^id _Nonnull{
        return [request buildRequest];
    }];
}

#pragma mark - Requests runner

- (BFTask *)performRequestRunningBlock:(nonnull id (^)(void))block
                     requestParameters:(BNRequestParameters)parameters
                     cancellationToken:(BFCancellationToken *)cancellationToken {
    if (cancellationToken.cancellationRequested) {
        return [BFTask cancelledTask];
    }
    
    // Check request parameters
    if (!(parameters.retryAttempts > 0)) {
        return block();
    }
    
    NSTimeInterval delay = parameters.throttleInterval > 0?:self.requestThrottleInterval;
    
    // Add some random to delay
    delay += self.requestThrottleInterval * ((double)(arc4random() & 0x0FFFF) / (double)0x0FFFF);
    
    return [self performRequestRunningBlock:block
                                      delay:delay
                                 forAttempt:parameters.retryAttempts
                          cancellationToken:cancellationToken];
}

- (BFTask *)performRequestRunningBlock:(nonnull id (^)(void))block
                                 delay:(NSTimeInterval)delay
                            forAttempt:(NSUInteger)attempt
                     cancellationToken:(BFCancellationToken *)cancellationToken {
    __weak typeof(self) wSelf = self;
    return [block() continueWithBlock:^id _Nullable(BFTask *task) {
        typeof(self) sSelf = wSelf;
        if (task.cancelled) {
            return task;
        }
        
        if (task.error && attempt > 1) {
            return [[BFTask taskWithDelay:delay cancellationToken:cancellationToken] continueWithBlock:^id _Nullable(BFTask<BFVoid> *task) {
                return [sSelf performRequestRunningBlock:block
                                                   delay:delay * 2
                                              forAttempt:attempt-1
                                       cancellationToken:cancellationToken];
            } cancellationToken:cancellationToken];
        }
        
        return task;
    } cancellationToken:cancellationToken];
}

@end
