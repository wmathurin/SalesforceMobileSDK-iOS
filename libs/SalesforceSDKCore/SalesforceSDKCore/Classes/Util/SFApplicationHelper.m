/*
 Copyright (c) 2016-present, salesforce.com, inc. All rights reserved.
 
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

#import "SFApplicationHelper.h"

@implementation SFApplicationHelper

+ (UIApplication*)sharedApplication {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if (UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return [UIApplication performSelector:@selector(sharedApplication)];
    }
    return nil;
}

+ (void)openURL:(NSURL*)url options:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion {
    UIApplication *app = [self sharedApplication];
    
    if (app) {
        SEL selector = @selector(openURL:options:completionHandler:);
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[[app class] instanceMethodSignatureForSelector:selector]];
        [invocation setTarget:app];
        [invocation setSelector:selector];
        [invocation setArgument:&url atIndex:2];
        [invocation setArgument:&options atIndex:3];
        [invocation setArgument:&completion atIndex:4];
        [invocation invoke];
    }
}

@end
