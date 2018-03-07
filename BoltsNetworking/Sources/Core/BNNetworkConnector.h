//
//  BNNetworkConnector.h
//  BoltsNetworking
//
//  Created by mainuser on 2/27/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BNRequest;
@class BFCancellationToken;
@class BFTask<Result>;

NS_ASSUME_NONNULL_BEGIN

@protocol BNNetworkConnector <NSObject>

- (BFTask<NSData *> *)performDataURLRequest:(NSURLRequest *)URLRequest forRequest:(BNRequest *)request cancellationToken:(BFCancellationToken *)cancellationToken;

//- (void)perform:(NSURLRequest *)request callback:(BNNeworkRequestCallback)callback;
//- (void)download:(NSURLRequest *)request callback:(BNNeworkDwoanloadRequestCallback)callback;

@end

NS_ASSUME_NONNULL_END
