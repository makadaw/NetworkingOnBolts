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

@interface BNRequestRunner ()
@property (nonatomic) id<BNNetworkConnector> connector;
@property (nonatomic) dispatch_queue_t workerQueue;

@end

@implementation BNRequestRunner

- (instancetype)initWithConnector:(id<BNNetworkConnector>)connector {
    if ((self = [super init])) {
        _connector = connector;
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
    } cancellationToken:cancellationToken] continueWithBlock:^id _Nullable(BFTask *task) {
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
        NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] init];
        [request buildRequest:URLRequest];
        return URLRequest;
    }];
}

#pragma mark - Requests runner

- (BFTask *)performRequestRunningBlock:(nonnull id (^)(void))block
                     cancellationToken:(BFCancellationToken *)cancellationToken {
    if (cancellationToken.cancellationRequested) {
        return [BFTask cancelledTask];
    }
    
    // TODO check retry policy here if we don't need it return block
//    if (!retry) {
        return block();
//    }
    
    // TODO Implement retry task wraper around main task.
    // Naive implementation:
//    __weak typeof(self) wSelf = self;
//    return [block() continueWithBlock:^id(BFTask *task) {
//        typeof(self) sSelf = wSelf;
//        if (task.cancelled) {
//            return task;
//        }
//
//        // TODO check number of attempts and adjust result here
//        return task;
//    } cancellationToken:cancellationToken];
}


@end
