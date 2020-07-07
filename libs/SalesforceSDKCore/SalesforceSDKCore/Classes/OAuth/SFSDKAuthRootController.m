//
//  SFSDKAuthRootController.m
//  SalesforceSDKCore
//
//  Created by Alex Sikora on 5/22/20.
//  Copyright © 2020 salesforce.com. All rights reserved.
//

#import "SFSDKAuthRootController.h"

@interface SFSDKAuthRootController ()

@end

@implementation SFSDKAuthRootController

- (ASPresentationAnchor)presentationAnchorForWebAuthenticationSession:(ASWebAuthenticationSession *)session API_AVAILABLE(ios(13.0)) {
    return self.view.window;
}

@end
