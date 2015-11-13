//
//  RPInstrumentation.h
//  Replay
//
//  Created by Jean Bovet on 9/4/15.
//  Copyright (c) 2015 Salesforce.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPInterceptor.h"

/** This class exposes API that allow to intercept
 method call and introspect the object being intercepted.
 It can be used to record timing & usage information for example.
 */
@interface RPInstrumentation : NSObject

/** Enable or disable this instrumentation instance
 */
@property (nonatomic) BOOL enabled;

/** Returns an instrumentation instance for the specified class
 */
+ (instancetype)instrumentationForClass:(Class)clazz;

/** Use this method to intercept the instance method specified by `selector`
 and provide a block that will be invoked before the method is executed.
 Note: the block contains a single argument which is the NSInvocation of the message.
 */
- (void)interceptInstanceMethod:(SEL)selector beforeInvocationBlock:(RPInterceptorInvocationCallback)before;

/** Use this method to intercept the instance method specified by `selector`
 and provide a block that will be invoked before the method is executed.
 Note: the block must have at least one argument which is the instance
 of the class being intercepted and then the arguments of the method.
 */
- (void)interceptInstanceMethod:(SEL)selector beforeBlock:(id)before;

/** Use this method to intercept the instance method specified by `selector`
 and provide a block that will be invoked after the method is executed.
 Note: the block contains a single argument which is the NSInvocation of the message.
 */
- (void)interceptInstanceMethod:(SEL)selector afterInvocationBlock:(RPInterceptorInvocationCallback)before;

/** Use this method to intercept the instance method specified by `selector`
 and provide a block that will be invoked after the method is executed.
 Note: the block must have at least one argument which is the instance
 of the class being intercepted and then the arguments of the method.
 */
- (void)interceptInstanceMethod:(SEL)selector afterBlock:(id)before;

/** Use this method to intercept the instance method specified by `selector`
 and provide a block that will be invoked instead of the method.
 Note: the block contains a single argument which is the NSInvocation of the message.
 */
- (void)interceptInstanceMethod:(SEL)selector replaceWithInvocationBlock:(RPInterceptorInvocationCallback)before;

/** Use this method to intercept the instance method specified by `selector`
 and provide a block that will be invoked instead of the method.
 Note: the block must have at least one argument which is the instance
 of the class being intercepted and then the arguments of the method.
 */
- (void)interceptInstanceMethod:(SEL)selector replaceWithBlock:(id)before;

/** Loads the array of instructions execute them. The instructions usually
 comes from a JSON file.
 @param instructions The array of instructions
 @param completion Optional completion block
 */
- (void)loadInstructions:(NSArray*)instructions completion:(dispatch_block_t)completion;

/** Start the timing measurement
 */
- (void)startMeasure;

/** Stop the timing measurement
 */
- (void)stopMeasure;

@end
