//
//  RPInterceptor.h
//  Replay
//
//  Created by Jean Bovet on 7/28/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RPInterceptorInvocationCallback)(NSInvocation *invocation);

/** The various mode of the interceptor
 */
typedef NS_ENUM(NSUInteger, RPInterceptorMode) {
    // Callback is invoked before method is executed
    RPInterceptorModeBefore,
    
    // Callback is invoked after method is executed
    RPInterceptorModeAfter,
    
    // Callback is invoked instead of the method
    RPInterceptorModeReplace,
};

/** This class provides a simple way to intercept an
 instance method or a class method and forward message
 to the original method if needed.
 */
@interface RPInterceptor : NSObject

/** The mode of the interceptor
 */
@property (nonatomic) RPInterceptorMode mode;

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

/** An optional block that will be invoked when the
 intercepted method is executed. The block must
 match the signature of the method except that
 there is a first argument that contains the instance
 of the class being intercepted. So the block must
 always starts with ^(id instance, <arguments of method here>)
 */
@property (nonatomic, copy) id targetMethodBlock;

/** An option block that will be invoked when the intercepted
 method is executed. It contains the invocation that is used
 to execute the method on the intercepted class.
 */
@property (nonatomic, copy) RPInterceptorInvocationCallback targetInvocationBlock;

/** Set this property to YES to enable the interceptor
*/
@property (nonatomic) BOOL enabled;

@end
