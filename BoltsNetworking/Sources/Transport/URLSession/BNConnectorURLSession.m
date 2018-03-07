//
//  BNConnectorURLSession.m
//  BoltsNetworking
//
//  Created by mainuser on 2/28/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "BNConnectorURLSession.h"
#import <Bolts/BFTask.h>
#import <Bolts/BFExecutor.h>
#import <Bolts/BFCancellationToken.h>
#import <Bolts/BFTaskCompletionSource.h>

@implementation BNConnectorURLSession

- (instancetype)init {
    if ((self = [super init])) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _sessionTaskQueue = dispatch_queue_create("bolts.networking.urlsession", 0);
    }
    return self;
}

- (void)dealloc {
    [self.session invalidateAndCancel];
}

#pragma mark <BNNetworkConnector>

- (BFTask<NSData *> *)performDataURLRequest:(NSURLRequest *)URLRequest
                                 forRequest:(BNRequest *)request
                          cancellationToken:(BFCancellationToken *)cancellationToken {
    if (cancellationToken.cancellationRequested) {
        return [BFTask cancelledTask];
    }
    
    __weak typeof(self) wSelf = self;
    return [BFTask taskFromExecutor:[BFExecutor immediateExecutor] withBlock:^id{
        typeof(self) sSelf = wSelf;
        if (cancellationToken.cancellationRequested) {
            return [BFTask cancelledTask];
        }
        
        // TODO maybe we need to call this tcs on the same executor as parent task
        BFTaskCompletionSource *tcs = [BFTaskCompletionSource taskCompletionSource];
        
        __block NSURLSessionDataTask *task = nil;
        dispatch_sync(sSelf.sessionTaskQueue, ^{
            task = [sSelf.session dataTaskWithRequest:URLRequest
                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if (data) {
                                            [tcs trySetResult:data];
                                        } else {
                                            if (error.code == NSURLErrorCancelled && [error.domain isEqualToString:NSURLErrorDomain]) {
                                                [tcs trySetCancelled];
                                            } else {
                                                [tcs trySetError:error];
                                            }
                                        }
            }];
            [task resume];
        });
        [cancellationToken registerCancellationObserverWithBlock:^{
            [task cancel];
        }];
        return tcs.task;
    }];
}


@end
