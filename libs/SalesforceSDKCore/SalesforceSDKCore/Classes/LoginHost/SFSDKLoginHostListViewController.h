//
//  SFSDKLoginHostListViewController.h
//  SalesforceSDKCore
//
//  Created by Jean Bovet on 9/20/11.
//  Copyright (c) 2011 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFSDKLoginHostDelegate.h"

@class SFSDKLoginHost;

/**
 * View controller that displays a list of hosts that can be used for login.
 * The user can either add a new host or select an existing host to reload the login web page.
 */
@interface SFSDKLoginHostListViewController : UITableViewController

/**
 * The object that acts as the delegate of the host list view controller.
 */
@property (nonatomic, weak) id<SFSDKLoginHostDelegate> delegate;

/**
 * Adds a new login host.
 * This method updates the underlying storage and refreshes the list of login hosts.
 * @see showAddLoginHost for presenting a UI for the user to enter a new login host.
 */
- (void)addLoginHost:(SFSDKLoginHost *)host;

/**
 * Use this method to display a view for adding a new login host.
 * If you have used a navigation controller to present this view controller, an add button is automatically added to the right bar button item.
 * @see addLoginHost: for adding a login host programmatically without showing the UI.
 */
- (void)showAddLoginHost;

@end
