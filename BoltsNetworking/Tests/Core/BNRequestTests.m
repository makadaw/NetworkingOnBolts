//
//  BNRequestTests.m
//  BoltsNetworking-Unit-Tests
//
//  Created by mainuser on 3/7/18.
//

#import <XCTest/XCTest.h>
#import <Expecta/Expecta.h>
#import <OCMock/OCMock.h>
#import "BNRequest.h"

@interface BNRequestTests : XCTestCase

@end

@implementation BNRequestTests

- (void)testURLRequest {
    NSURLRequest *URLRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://google.com"]];
    
    BNRequest *req = [[BNRequest alloc] initWithRequestBuilder:^NSURLRequest * _Nonnull{
        return URLRequest;
    } responseParser:^BNResult * _Nonnull(id result) {
        
    } parameters:(BNRequestParameters) completion:^(id result, NSError *error) {
        
    }];
    expect([req buildRequest]).to.equal(URLRequest);
}

@end
