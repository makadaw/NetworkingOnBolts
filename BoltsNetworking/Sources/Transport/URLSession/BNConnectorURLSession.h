//
//  BNConnectorURLSession.h
//  BoltsNetworking
//
//  Created by mainuser on 2/28/18.
//  Copyright © 2018 xcode. All rights reserved.
//

#import "BNNetworkConnector.h"

@interface BNConnectorURLSession : NSObject <BNNetworkConnector>
@property (nonatomic) NSURLSession *session;
@property (nonatomic) dispatch_queue_t sessionTaskQueue;

@end
