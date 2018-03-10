//
//  QuoteRequestBuilder.m
//  Example
//
//  Created by mainuser on 3/10/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "QuoteRequestBuilder.h"

@implementation QuoteRequestBuilder

- (NSURLRequest *)requestWithEndpoint:(NSString*)name {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://quotes.rest/%@.json", name]];
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    [req addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [req addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    return [req copy];
}

@end
