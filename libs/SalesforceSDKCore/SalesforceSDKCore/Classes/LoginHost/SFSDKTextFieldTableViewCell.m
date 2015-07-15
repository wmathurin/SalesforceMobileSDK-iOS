//
//  SFSDKTextFieldTableViewCell.m
//  SalesforceSDKCore
//
//  Created by Behzad Richey on 7/14/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

#import "SFSDKTextFieldTableViewCell.h"

// Insets used to determine the proper size for the editable field presented in the table view cell.
static UIEdgeInsets const SFSDKTextFieldCellInsets = { 10.0, 10.0, 10.0, 30.0 };

@interface SFSDKTextFieldTableViewCell ()

@property (nonatomic, strong, readwrite) UITextField *textField;

@end

@implementation SFSDKTextFieldTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self.contentView addSubview:self.textField];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.textField.frame = UIEdgeInsetsInsetRect(self.contentView.frame, SFSDKTextFieldCellInsets);
}

@end
