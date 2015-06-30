//
//  SFSDKNewLoginHostViewController.h
//  SalesforceSDKCore
//
//  Created by Jean Bovet on 9/20/11.
//  Copyright (c) 2011 Salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SFSDKLoginHostListViewController;

/**
 * View controller that allows the user to enter a new login host that contains
 * a host (the server address) and an optional name.
 */
@interface SFSDKNewLoginHostViewController : UITableViewController <UITextFieldDelegate>

// The server text field
@property (nonatomic, strong) UITextField *server;

// The name text field
@property (nonatomic, strong) UITextField *name;

// A reference to the login host list view controller used to add the host to the list of login hosts
// and to also properly resize the popover controller.
@property (nonatomic, weak) SFSDKLoginHostListViewController *loginHostListViewController;

@end
