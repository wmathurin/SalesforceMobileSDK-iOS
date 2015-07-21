//
//  SFSDKNewLoginHostViewController.m
//  SalesforceSDKCore
//
//  Created by Jean Bovet on 9/20/11.
//  Copyright (c) 2011 Salesforce.com. All rights reserved.
//

#import "SFSDKNewLoginHostViewController.h"
#import "SFSDKLoginHostListViewController.h"
#import "SFSDKLoginHost.h"
#import "SFSDKResourceUtils.h"
#import "SFSDKTextFieldTableViewCell.h"

@implementation SFSDKNewLoginHostViewController

static NSString * const SFSDKNewLoginHostCellIdentifier = @"SFSDKNewLoginHostCellIdentifier";

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.bounds.size.width, 0.01f)];
    
    // Disable the scroll because there is enough space
    // on both the iPhone and iPad to display the two editing rows.
    self.tableView.scrollEnabled = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                            target:self action:@selector(addNewServer:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.title = [SFSDKResourceUtils localizedString:@"loginAddServer"];
    
    [self.tableView registerClass:[SFSDKTextFieldTableViewCell class] forCellReuseIdentifier:SFSDKNewLoginHostCellIdentifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Set the size of this view so any popover controller will resize to fit
    CGRect r = [self.tableView rectForSection:0];
    
    CGSize size = CGSizeMake(380, r.size.height);
    self.preferredContentSize = size;
    self.loginHostListViewController.preferredContentSize = size;
    
    self.preferredContentSize = size;
    
    // Make sure to also set the content size of the other view controller, otherwise the popover won't
    // resize if this view is smaller than the previous view.
    self.loginHostListViewController.preferredContentSize = size;
}

#pragma mark - Actions

/**
 * Invoked when the user taps on the done button to add the login host to the list of hosts.
 */
- (void)addNewServer:(id)sender {
    [self.loginHostListViewController addLoginHost:[SFSDKLoginHost hostWithName:self.name.text host:self.server.text deletable:YES]];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;   // One row for the host and one for the name
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SFSDKTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SFSDKNewLoginHostCellIdentifier forIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    cell.textField.delegate = self;
    cell.textField.tag = indexPath.row;
    
    // Create the text field for each specific row.
    if (0 == indexPath.row) {
        cell.textField.placeholder = [SFSDKResourceUtils localizedString:@"loginServerUrl"];
        cell.textField.keyboardType = UIKeyboardTypeURL;
        cell.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        [cell.textField becomeFirstResponder];
        self.server = cell.textField;
    } else {
        cell.textField.placeholder = [SFSDKResourceUtils localizedString:@"loginServerName"];
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        self.name = cell.textField;
    }
    
    return cell;
}

#pragma mark - Text field delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Enable the Done button only if there is something in the URL field
    if (textField == self.server) {
        NSString *resultingString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.navigationItem.rightBarButtonItem.enabled = [resultingString length] > 0;
    }
    return YES;
}

@end
