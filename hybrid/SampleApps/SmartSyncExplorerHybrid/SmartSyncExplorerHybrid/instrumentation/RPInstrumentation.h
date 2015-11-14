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
 Note: each block contains a single argument which is the NSInvocation of the message.
 @param selector The selector to intercept
 @param before An optional block invoked before the selector is executed
 @param before An optional block invoked after the selector is executed
 */
- (void)interceptInstanceMethod:(SEL)selector beforeBlock:(RPInterceptorInvocationCallback)before afterBlock:(RPInterceptorInvocationCallback)after;

/** Use this method to intercept the instance method specified by `selector`
 and provide a block that will be invoked instead of the method.
 Note: the block contains a single argument which is the NSInvocation of the message.
 */
- (void)interceptInstanceMethod:(SEL)selector replaceWithInvocationBlock:(RPInterceptorInvocationCallback)before;

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
