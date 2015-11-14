//
//  RPInterceptor.h
//  Replay
//
//  Created by Jean Bovet on 7/28/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RPInterceptorInvocationCallback)(NSInvocation *invocation);

/** This class provides a simple way to intercept an
 instance method or a class method and forward message
 to the original method if needed.
 */
@interface RPInterceptor : NSObject

/** Class to intercept
*/
@property (nonatomic, strong) Class classToIntercept;

/** Selector to intercept
*/
@property (nonatomic) SEL selectorToIntercept;

/** YES if the `selectorToIntercept` is an instance
* method, NO if it's a class method.
*/
@property (nonatomic) BOOL instanceMethod;

// The various blocks of interceptions (each of them can be nil)
@property (nonatomic, copy) RPInterceptorInvocationCallback targetBeforeBlock;
@property (nonatomic, copy) RPInterceptorInvocationCallback targetReplaceBlock;
@property (nonatomic, copy) RPInterceptorInvocationCallback targetAfterBlock;

/** Set this property to YES to enable the interceptor
*/
@property (nonatomic) BOOL enabled;

@end
