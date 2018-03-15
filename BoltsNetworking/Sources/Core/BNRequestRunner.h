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
@protocol BNNetworkConnector;

NS_ASSUME_NONNULL_BEGIN

typedef void(^BNProgressBlock)(float);

@protocol BNRequestTask <NSObject>

- (void)cancel;

@end

@interface BNRequestRunner : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithConnector:(id<BNNetworkConnector>)connector requestBuilderRegistry:(BNRequestBuildersRegistry *)builderRegistry NS_DESIGNATED_INITIALIZER;

- (id<BNRequestTask>)runRequestAsync:(BNRequest *)request;

- (id<BNRequestTask>)runFileDownloadRequest:(BNRequest *)request
                              progressBlock:(nullable BNProgressBlock)progressBlock;

@end

NS_ASSUME_NONNULL_END
