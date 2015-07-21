//
//  SFSDKTextFieldTableViewCell.h
//  SalesforceSDKCore
//
//  Created by Behzad Richey on 7/14/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 * A custom UITableViewCell which contains a UITextField for inserting and editing text.
 */
@interface SFSDKTextFieldTableViewCell : UITableViewCell

@property (nonatomic, strong, readonly) UITextField *textField;

@end
