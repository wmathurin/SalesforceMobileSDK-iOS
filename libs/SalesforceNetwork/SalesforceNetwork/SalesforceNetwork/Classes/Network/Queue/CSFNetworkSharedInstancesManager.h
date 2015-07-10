//
//  CSFNetworkSharedInstancesManager.h
//  SalesforceNetwork
//
//  Created by João Neves on 7/6/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SalesforceSDKCore/SFAuthenticationManager.h>
@class CSFNetwork;

@interface CSFNetworkSharedInstancesManager : NSObject <SFAuthenticationManagerDelegate>

- (CSFNetwork*)sharedInstanceForUserAccount:(SFUserAccount*)user;

@end
