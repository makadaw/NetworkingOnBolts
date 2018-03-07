//
//  ViewController.m
//  Example
//
//  Created by mainuser on 2/21/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "ViewController.h"
#import "QuoteClient.h"

@interface ViewController ()
@property (nonatomic) QuoteClient *client;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.client = [QuoteClient client];
}

- (IBAction)makeRequest {
    [self.client quoteOfTheDay:^(Quote *quote, NSError *error) {
        if (quote) {
            NSLog(@"Quote of the day: %@", quote.text);
        } else {
            NSLog(@"Request error: %@", error);
        }
    }];
}

@end
