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

@implementation SFSDKNewLoginHostViewController

// Insets used to determine the proper size for the editable field presented
// in the table view cell.
static UIEdgeInsets const kCellInsets = { 10.0, 10.0, 10.0, 30.0 };

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
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SFSDKNewLoginHostCellIdentifier];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SFSDKNewLoginHostCellIdentifier forIndexPath:indexPath];

    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Magic numbers to get the proper inset (maybe there is a better way?)
    CGRect r = UIEdgeInsetsInsetRect(cell.contentView.frame, kCellInsets);
    
    // Create the text field for each specific row
    UITextField *textField = [[UITextField alloc] initWithFrame:r];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.delegate = self;
    if (0 == indexPath.row) {
        textField.placeholder = [SFSDKResourceUtils localizedString:@"loginServerUrl"];
        textField.keyboardType = UIKeyboardTypeURL;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        [textField becomeFirstResponder];
        self.server = textField;
    } else {
        textField.placeholder = [SFSDKResourceUtils localizedString:@"loginServerName"];
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        self.name = textField;
    }
    textField.tag = indexPath.row;
    [cell.contentView addSubview:textField];
    
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
