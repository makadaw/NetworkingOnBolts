//
//  BNRequestRunner.h
//  BoltsNetworking
//
//  Created by mainuser on 2/27/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BNRequest;
@class BNRequestBuildersRegistry;
@class BFTask<Result>;
@class BFCancellationToken;
@protocol BNNetworkConnector;

NS_ASSUME_NONNULL_BEGIN

typedef void(^BNProgressBlock)(float);

@interface BNRequestRunner : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConnector:(id<BNNetworkConnector>)connector requestBuilderRegistry:(BNRequestBuildersRegistry *)builderRegistry NS_DESIGNATED_INITIALIZER;

- (BFTask<__kindof id> *)runRequestAsync:(BNRequest *)request cancellationToken:(nullable BFCancellationToken *)cancellationToken;

- (BFTask<NSURL *> *)runFileDownloadRequest:(BNRequest *)request
                          cancellationToken:(nullable BFCancellationToken *)cancellationToken
                              progressBlock:(nullable BNProgressBlock)progressBlock;

@end

NS_ASSUME_NONNULL_END
