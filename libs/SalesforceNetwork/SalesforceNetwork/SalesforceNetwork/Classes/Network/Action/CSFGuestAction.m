//
//  CSFGuestAction.m
//  SalesforceNetwork
//
//  Created by Bharath Hariharan on 7/8/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

#import "CSFGuestAction.h"

@implementation CSFGuestAction

- (instancetype)initWithUrlAndResponseBlock:(NSURL *)requestUrl responseBlock:(CSFActionResponseBlock)responseBlock {
    self = [super initWithResponseBlock:responseBlock];
    if (self) {
        self.method = @"GET";
        _requestUrl = requestUrl;
        self.requiresAuthentication = NO;
    }
    return self;
}

- (NSURLRequest*)createURLRequest:(NSError**)error {
    NSMutableURLRequest *request = nil;
    if (_requestUrl) {
        request = [NSMutableURLRequest requestWithURL:_requestUrl cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:self.timeoutInterval];
        request.HTTPMethod = self.method;
        request.allHTTPHeaderFields = [self headersForAction];
    }
    return request;
}

@end