//
//  SFSDKLoginHostStorage.h
//  SalesforceSDKCore
//
//  Created by Jean Bovet on 9/22/11.
//  Copyright (c) 2011 Salesforce.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFSDKLoginHost;

/**
 * This class manages the list of login hosts as well its persistence.
 * Currently this list is persisted in the user defaults.
 */
@interface SFSDKLoginHostStorage : NSObject

/**
 * Returns the shared instance of this class.
 */
+ (SFSDKLoginHostStorage *)sharedInstance;

/**
 * Adds a new login host.
 */
- (void)addLoginHost:(SFSDKLoginHost *)loginHost;

/**
 * Removes the login host at the specified index.
 */
- (void)removeLoginHostAtIndex:(NSUInteger)index;

/**
 * Returns the index of the specified host if exists.
 */
- (NSUInteger)indexOfLoginHost:(SFSDKLoginHost *)host;

/**
 * Returns the login host at the specified index.
 */
- (SFSDKLoginHost *)loginHostAtIndex:(NSUInteger)index;

/**
 * Returns the login host with a particular host adress if any.
 */
- (SFSDKLoginHost *)loginHostForHostAddress:(NSString *)hostAddress;

/**
 * Removes all the login hosts.
 */
- (void)removeAllLoginHosts;

/**
 * Returns the number of login hosts.
 */
- (NSUInteger)numberOfLoginHosts;

/**
 * Stores all the login host except the non-deletable ones in the user defaults.
 */
- (void)save;

@end
