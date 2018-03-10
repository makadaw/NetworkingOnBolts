//
//  BNRequestBuildersRegistry.h
//  BoltsNetworking
//
//  Created by mainuser on 3/10/18.
//

#import <Foundation/Foundation.h>

@protocol BNRequestBuilder;

NS_ASSUME_NONNULL_BEGIN

@interface BNRequestBuildersRegistry : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDefaultBuilder:(id<BNRequestBuilder>)defaultBuilder NS_DESIGNATED_INITIALIZER;

- (void)registerRequestBuilder:(NSObject<BNRequestBuilder>*)builder;
- (id<BNRequestBuilder>)builderForClass:(nullable Class __unsafe_unretained)class;

@end

NS_ASSUME_NONNULL_END
