//
//  SFSDKAuthRootController.h
//  SalesforceSDKCore
//
//  Created by Alex Sikora on 5/22/20.
//  Copyright © 2020 salesforce.com. All rights reserved.
//

#import "SFSDKRootController.h"
#import <AuthenticationServices/AuthenticationServices.h>
NS_ASSUME_NONNULL_BEGIN

@interface SFSDKAuthRootController : SFSDKRootController <ASWebAuthenticationPresentationContextProviding>

@end

NS_ASSUME_NONNULL_END
