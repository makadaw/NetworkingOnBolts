//
//  QuoteClient.m
//  Example
//
//  Created by mainuser on 2/27/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "QuoteClient.h"
#import "QuoteRequestBuilder.h"

#import "BNRequestRunner.h"
#import "BNRequest.h"
#import "BNConnectorURLSession.h"
#import "BNRequestBuildersRegistry.h"

// Need to remove
#import <Bolts/BFCancellationTokenSource.h>

// https://quotes.rest/

@interface Quote ()

@end

@interface BNRequest (Quote)
+ (instancetype)requestWithName:(NSString *)name responseParser:(BNResponseParser)parser completion:(BNRequestCompletion)completion;
@end

@interface QuoteClient ()
@property (nonatomic) BNRequestRunner *requestRunner;
@end

@implementation QuoteClient

+ (QuoteClient*)client {
    QuoteRequestBuilder *builder = [[QuoteRequestBuilder alloc] init];
    // TODO Client do not need to create registry manually
    BNRequestBuildersRegistry *registry = [[BNRequestBuildersRegistry alloc] initWithDefaultBuilder:builder];
    BNRequestRunner *runner = [[BNRequestRunner alloc] initWithConnector:[[BNConnectorURLSession alloc] init] requestBuilderRegistry:registry];
    return [[[self class] alloc] initWithRequestRunner:runner];
}

- (instancetype)initWithRequestRunner:(BNRequestRunner*)requestRunner {
    if ((self = [self init])) {
        _requestRunner = requestRunner;
    }
    return self;
}

- (void)quoteOfTheDay:(QODCallback)callback {
    BNRequest *request = [BNRequest requestWithName:@"qod"
                                     responseParser:^BNResult<Quote*> *(NSData *response) {
                                         return [BNResult value:[Quote new]];
                                     }
                                         completion:callback];
    BFCancellationTokenSource *cancelationSource = [BFCancellationTokenSource cancellationTokenSource];
    [self.requestRunner runRequestAsync:request cancellationToken:cancelationSource.token];
}

@end

@implementation BNRequest (Quote)

+ (instancetype)requestWithName:(NSString *)name responseParser:(BNResponseParser)parser completion:(BNRequestCompletion)completion {
    return [[BNRequest alloc] initWithRequestBuilder:^NSURLRequest *(QuoteRequestBuilder *builder) {
        return [builder requestWithEndpoint:name];
    } responseParser:parser parameters:BNDefaultParameters() completion:completion];
}

@end

@implementation Quote

@end
