//
//  SFSDKLoginHost.m
//  SalesforceSDKCore
//
//  Created by Jean Bovet on 9/22/11.
//  Copyright (c) 2011 Salesforce.com. All rights reserved.
//

#import "SFSDKLoginHost.h"

@interface SFSDKLoginHost ()

@property (readwrite, getter=isDeletable) BOOL deletable;

@end

@implementation SFSDKLoginHost

+ (SFSDKLoginHost *)hostWithName:(NSString *)name host:(NSString *)host deletable:(BOOL)deletable {
    SFSDKLoginHost *loginHost = [[SFSDKLoginHost alloc] init];
    
    loginHost.name = name ? : @"";  // Ensure name is not nil.
    if ([host hasSuffix:@"/"]) {
        loginHost.host = [host substringToIndex:host.length-1];
    } else {
        loginHost.host = host;
    }
    loginHost.deletable = deletable;
    
    return loginHost;
}

@end
