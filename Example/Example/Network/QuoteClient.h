//
//  QuoteClient.h
//  Example
//
//  Created by mainuser on 2/27/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import <Foundation/Foundation.h>

// https://quotes.rest/

@class BNRequestRunner;

@interface Quote: NSObject
@property (nonatomic, readonly) NSString *text;
@property (nonatomic, readonly) NSString *author;

@end

typedef void(^QODCallback)(Quote *, NSError *);

@interface QuoteClient : NSObject

+ (QuoteClient*)client;
- (instancetype)initWithRequestRunner:(BNRequestRunner*)requestRunner;

- (void)quoteOfTheDay:(QODCallback)callback;

@end
