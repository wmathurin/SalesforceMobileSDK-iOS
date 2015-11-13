//
//  RPInstrumentation.m
//  Replay
//
//  Created by Jean Bovet on 9/4/15.
//  Copyright (c) 2015 Salesforce.com. All rights reserved.
//

#import "RPInstrumentation.h"
#import "RPInterceptor.h"

@interface RPInstrumentation ()

@property (nonatomic) Class clazz;

@property (nonatomic, strong) NSMutableArray *interceptors;

@property (nonatomic, strong) NSMutableDictionary *collector;

@property (nonatomic, strong) NSString *sessionKey;
@property (nonatomic, strong) NSString *sessionValue;

@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;

@end

@implementation RPInstrumentation

+ (instancetype)instrumentationForClass:(Class)clazz {
    RPInstrumentation *perf = [[RPInstrumentation alloc] init];
    perf.clazz = clazz;
    return perf;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.interceptors = [NSMutableArray array];
        self.collector = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    if (_enabled != enabled) {
        [self willChangeValueForKey:@"enabled"];
        _enabled = enabled;
        for (RPInterceptor *interceptor in self.interceptors) {
            interceptor.enabled = enabled;
        }
        [self didChangeValueForKey:@"enabled"];
    }
}

- (void)interceptInstanceMethod:(SEL)selector beforeInvocationBlock:(RPInterceptorInvocationCallback)before {
    [self interceptInstanceMethod:selector mode:RPInterceptorModeBefore invocationBlock:before];
}

- (void)interceptInstanceMethod:(SEL)selector beforeBlock:(id)before {
    [self interceptInstanceMethod:selector mode:RPInterceptorModeBefore block:before];
}

- (void)interceptInstanceMethod:(SEL)selector afterInvocationBlock:(RPInterceptorInvocationCallback)before {
    [self interceptInstanceMethod:selector mode:RPInterceptorModeAfter invocationBlock:before];
}

- (void)interceptInstanceMethod:(SEL)selector afterBlock:(id)before {
    [self interceptInstanceMethod:selector mode:RPInterceptorModeAfter block:before];
}

- (void)interceptInstanceMethod:(SEL)selector replaceWithInvocationBlock:(RPInterceptorInvocationCallback)before {
    [self interceptInstanceMethod:selector mode:RPInterceptorModeReplace invocationBlock:before];
}

- (void)interceptInstanceMethod:(SEL)selector replaceWithBlock:(id)before {
    [self interceptInstanceMethod:selector mode:RPInterceptorModeReplace block:before];
}

- (void)interceptInstanceMethod:(SEL)selector mode:(RPInterceptorMode)mode invocationBlock:(RPInterceptorInvocationCallback)callback {
    RPInterceptor *interceptor = [[RPInterceptor alloc] init];
    interceptor.mode = mode;
    interceptor.classToIntercept = self.clazz;
    interceptor.selectorToIntercept = selector;
    interceptor.targetInvocationBlock = callback;
    interceptor.instanceMethod = YES;
    interceptor.enabled = YES;
    [self.interceptors addObject:interceptor];
}

- (void)interceptInstanceMethod:(SEL)selector mode:(RPInterceptorMode)mode block:(id)callback {
    RPInterceptor *interceptor = [[RPInterceptor alloc] init];
    interceptor.mode = mode;
    interceptor.classToIntercept = self.clazz;
    interceptor.selectorToIntercept = selector;
    interceptor.targetMethodBlock = callback;
    interceptor.instanceMethod = YES;
    interceptor.enabled = YES;
    [self.interceptors addObject:interceptor];
}

#pragma mark - Driven

- (void)loadInstructions:(NSArray*)instructions completion:(dispatch_block_t)completion {
    for (NSDictionary *instruction in instructions) {
        self.clazz = NSClassFromString(instruction[@"class"]);
        NSDictionary *session = instruction[@"session"];
        if (session) {
            self.sessionKey = session.allKeys[0];
            self.sessionValue = session.allValues[0];
        }
        
        for (NSDictionary *interceptor in instruction[@"intercept"]) {
            SEL selector = NSSelectorFromString(interceptor[@"selector"]);
            NSString *action = interceptor[@"action"];
            NSArray *keys = interceptor[@"keys"];
            
            [self interceptInstanceMethod:selector beforeInvocationBlock:^(NSInvocation *invocation) {
                if ([self isInstanceSession:invocation.target]) {
                    [self collectKeys:keys invocation:invocation selector:selector];
                    if ([action isEqualToString:@"start"]) {
                        [self startMeasure];
                    }
                    if ([action isEqualToString:@"end"]) {
                        [self stopMeasure];
                        if (completion) completion();
                    }
                }
            }];
        }
        
        self.enabled = YES;
    }
}

- (BOOL)isInstanceSession:(id)instance {
    if (nil == self.sessionKey) {
        return YES;
    }
    
    id value = [instance valueForKey:self.sessionKey];
    return [self.sessionValue isEqualToString:[value description]];
}

- (void)collectKeys:(NSArray*)keys invocation:(NSInvocation*)invocation selector:(SEL)selector {
    if (nil == keys) {
        return;
    }
    
    id instance = invocation.target;

    NSMutableDictionary *collection = [NSMutableDictionary dictionary];

    NSMutableArray *args = [NSMutableArray array];
    for (NSUInteger index=2; index<invocation.methodSignature.numberOfArguments; index++) {
        // TODO support for non-object argument
        __unsafe_unretained id arg = nil;
        [invocation getArgument:&arg atIndex:index];
        if (arg) {
            [args addObject:[arg description]];
        }
    }
    collection[@"args"] = args;
    
    for (NSString *key in keys) {
        id value = [instance valueForKey:key];
        if (value) {
            collection[key] = value;
        } else {
            collection[key] = @"nil";
        }
    }
    self.collector[NSStringFromSelector(selector)] = collection;
}

#pragma mark - Measure

- (void)startMeasure {
    self.startTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)stopMeasure {
    self.endTime = [NSDate timeIntervalSinceReferenceDate];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<%@: %p, duration=%.2f, collector=%@>", NSStringFromClass([self class]), self, self.endTime-self.startTime, self.collector];
}

@end
