//
//  QuoteClient.m
//  Example
//
//  Created by mainuser on 2/27/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "QuoteClient.h"
#import "BNRequestRunner.h"
#import "BNRequest.h"
#import "BNConnectorURLSession.h"
#import <Bolts/BFCancellationTokenSource.h>

// https://quotes.rest/

@interface Quote ()

@end

@interface QuoteClient ()
@property (nonatomic) BNRequestRunner *requestRunner;
@end

@implementation QuoteClient

+ (QuoteClient*)client {
    BNRequestRunner *runner = [[BNRequestRunner alloc] initWithConnector:[[BNConnectorURLSession alloc] init]];
    return [[[self class] alloc] initWithRequestRunner:runner];
}

- (instancetype)initWithRequestRunner:(BNRequestRunner*)requestRunner {
    if ((self = [self init])) {
        _requestRunner = requestRunner;
    }
    return self;
}

- (void)quoteOfTheDay:(QODCallback)callback {
    BNRequest *request = [[BNRequest alloc] initWithRequestBuilder:^NSURLRequest *(){
        return [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://quotes.rest/qod.json"]];
    }
                                                    responseParser:^BNResult *(NSData *response) {
                                                        return [BNResult value:[Quote new]];
                                                    }
                                                        parameters:BNDefaultParameters()
                                                        completion:callback];
    BFCancellationTokenSource *cancelationSource = [BFCancellationTokenSource cancellationTokenSource];
    [self.requestRunner runRequestAsync:request cancellationToken:cancelationSource.token];
}

@end


@implementation Quote

@end
