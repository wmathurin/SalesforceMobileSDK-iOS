//
//  SFSDKLoginHost.h
//  SalesforceSDKCore
//
//  Created by Jean Bovet on 9/22/11.
//  Copyright (c) 2011 Salesforce.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Class that encapsulates the information about a login host.
 */
@interface SFSDKLoginHost : NSObject

// The name of the login host
@property (nonatomic, copy) NSString *name;

// The server address of the login host
@property (nonatomic, copy) NSString *host;

// Indicates whether this login host can be deleted
@property (readonly, getter=isDeletable) BOOL deletable;

/**
 * Returns a new login host instance with the specified parameters.
 */
+ (SFSDKLoginHost *)hostWithName:(NSString *)name host:(NSString *)host deletable:(BOOL)deletable;

@end
