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
#import "BNRequestBuildersRegistry.h"
#import "BNRequestRetryStrategy.h"

@interface BNRequestRunner ()
@property (nonatomic) id<BNNetworkConnector> connector;
@property (nonatomic) BNRequestBuildersRegistry *builderRegistry;
@property (nonatomic) dispatch_queue_t workerQueue;
@property (assign) NSTimeInterval requestThrottleInterval;

@end

@implementation BNRequestRunner

- (instancetype)initWithConnector:(id<BNNetworkConnector>)connector
           requestBuilderRegistry:(BNRequestBuildersRegistry *)builderRegistry {
    if ((self = [super init])) {
        _connector = connector;
        _builderRegistry = builderRegistry;
        _workerQueue = dispatch_queue_create("bolts.networking.runner", DISPATCH_QUEUE_CONCURRENT);
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
    } request:request cancellationToken:cancellationToken]
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
        return [request buildRequestWithBuilder:[self.builderRegistry builderForClass:nil]];
    }];
}

#pragma mark - Requests runner

- (BFTask *)performRequestRunningBlock:(nonnull id (^)(void))block
                               request:(BNRequest *)request
                     cancellationToken:(BFCancellationToken *)cancellationToken {
    if (cancellationToken.cancellationRequested) {
        return [BFTask cancelledTask];
    }
    BNRequestRetryStrategy *retryStrategy = request.retryStrategy;
    // Check retry strategy. If we don't need to retry this request return a normal task
    if (!retryStrategy && ![retryStrategy needsToRetry]) {
        return block();
    }
    return [self performRequestRunningBlock:block
                              retryStrategy:retryStrategy
                          cancellationToken:cancellationToken];
}

- (BFTask *)performRequestRunningBlock:(nonnull id (^)(void))block
                         retryStrategy:(BNRequestRetryStrategy *)retryStrategy
                     cancellationToken:(BFCancellationToken *)cancellationToken {
    __weak typeof(self) wSelf = self;
    return [block() continueWithBlock:^id _Nullable(BFTask *task) {
        typeof(self) sSelf = wSelf;
        if (task.cancelled) {
            return task;
        }
        
        if (task.error && [retryStrategy needsToRetry]) {
            return [[BFTask taskWithDelay:retryStrategy.delay cancellationToken:cancellationToken] continueWithBlock:^id _Nullable(BFTask<BFVoid> *task) {
                [retryStrategy countAttempt];
                return [sSelf performRequestRunningBlock:block
                                           retryStrategy:retryStrategy
                                       cancellationToken:cancellationToken];
            } cancellationToken:cancellationToken];
        }
        
        return task;
    } cancellationToken:cancellationToken];
}

@end
