/*
 SFSDKViewUtils.m
 SalesforceSDKCore
 
 Created by Raj Rao on 2/5/19.
 Copyright (c) 2019-present, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <UIKit/UIKit.h>
#import "SFSDKViewUtils.h"
#import "SFSDKViewControllerConfig.h"

@implementation SFSDKViewUtils

+ (void)styleNavigationBar:(UINavigationBar *)navigationBar config:(SFSDKViewControllerConfig *) config {

    if (!navigationBar && !config) {
        return;
    }
    
    if (config.navBarColor) {
        navigationBar.standardAppearance.backgroundColor = config.navBarColor;
        navigationBar.backgroundColor = config.navBarColor;
    }
    
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    if (config.navBarTintColor) {
        navigationBar.tintColor = config.navBarTintColor;
        [textAttributes setObject:config.navBarTintColor forKey:NSForegroundColorAttributeName];
    } else {
        // default color
        navigationBar.tintColor = [UIColor whiteColor];
    }
    
    if (config.navBarTitleColor){
        [textAttributes setObject:config.navBarTitleColor forKey:NSForegroundColorAttributeName];
    }
    
    if (config.navBarFont) {
        [textAttributes setObject:config.navBarFont forKey:NSFontAttributeName];
    }
    
    if ([textAttributes count] > 0) {
        navigationBar.standardAppearance.titleTextAttributes = textAttributes;
        [navigationBar setTitleTextAttributes:textAttributes];
    }
}

+ ( UIImage * _Nonnull )headerBackgroundImage:(UIColor *)color {
    UIImage *backgroundImage = [self  imageFromColor:color];
    return backgroundImage;
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
