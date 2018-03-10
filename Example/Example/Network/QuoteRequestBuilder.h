//
//  QuoteRequestBuilder.h
//  Example
//
//  Created by mainuser on 3/10/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNRequestBuilder.h"

@interface QuoteRequestBuilder : NSObject <BNRequestBuilder>

- (NSURLRequest *)requestWithEndpoint:(NSString*)name;

@end
