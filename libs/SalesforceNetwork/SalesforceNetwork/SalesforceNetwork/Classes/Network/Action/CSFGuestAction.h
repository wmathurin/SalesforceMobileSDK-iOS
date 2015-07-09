//
//  CSFGuestAction.h
//  SalesforceNetwork
//
//  Created by Bharath Hariharan on 7/8/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

#import "CSFAction.h"

@interface CSFGuestAction : CSFAction

@property (nonatomic, copy) NSURL *requestUrl;

- (instancetype)initWithUrlAndResponseBlock:(NSURL *)requestUrl responseBlock:(CSFActionResponseBlock)responseBlock;

@end