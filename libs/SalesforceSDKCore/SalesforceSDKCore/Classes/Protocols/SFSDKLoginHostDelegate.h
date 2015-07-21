//
//  SFSDKLoginHostDelegate.h
//  SalesforceSDKCore
//
//  Created by Behzad Richey on 6/30/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

@class SFSDKLoginHostListViewController;

/**
 * Use the SFSDKLoginHostDelegate to be notified of the actions taken by the user on the login host list view controller.
 */
@protocol SFSDKLoginHostDelegate <NSObject>

@optional

/**
 * Notifies the delegate that a login host has been selected by the user.
 * This will be a good time to dismiss the host list view controller.
 * @param hostListViewController The instance sending this message.
 */
- (void)hostListViewControllerDidSelectLoginHost:(SFSDKLoginHostListViewController *)hostListViewController;

/**
 * Notifies the delegate that a login host has been added to the list of hosts.
 * @param hostListViewController The instance sending this message.
 */
- (void)hostListViewControllerDidAddLoginHost:(SFSDKLoginHostListViewController *)hostListViewController;

@end