//
//  CSFNetworkSharedInstancesManager.m
//  SalesforceNetwork
//
//  Created by João Neves on 7/6/15.
//  Copyright (c) 2015 salesforce.com. All rights reserved.
//

#import "CSFNetworkSharedInstancesManager.h"
#import "CSFNetwork+Internal.h"

static inline NSString *CSFNetworkInstanceKey(SFUserAccount *user) {
    return [NSString stringWithFormat:@"%@-%@-%@", user.credentials.organizationId, user.credentials.userId, user.communityId];
}

@interface CSFNetworkSharedInstancesManager() {
    NSMutableDictionary* _sharedInstances;
}

@end

@implementation CSFNetworkSharedInstancesManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _sharedInstances = [NSMutableDictionary new];
        [[SFAuthenticationManager sharedManager] addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [[SFAuthenticationManager sharedManager] removeDelegate:self];
}

- (void)removeSharedInstanceForUserAccount:(SFUserAccount*)account {
    @synchronized(_sharedInstances) {
        NSString* key = CSFNetworkInstanceKey(account);
        [_sharedInstances removeObjectForKey:key];
    }
}

#pragma mark - Public Methods

- (CSFNetwork*)sharedInstanceForUserAccount:(SFUserAccount*)account {
    CSFNetwork* instance = nil;
    
    if (![account.accountIdentity isEqual:[SFUserAccountManager sharedInstance].temporaryUserIdentity]) {
        @synchronized(_sharedInstances) {
            NSString* key = CSFNetworkInstanceKey(account);
            instance = _sharedInstances[key];
            if (!instance) {
                instance = [[CSFNetwork alloc] initWithUserAccount:account];
                if (instance) {
                    _sharedInstances[key] = instance;
                }
            }
        }
    }
    
    return instance;
}

#pragma mark - SFAuthenticationManagerDelegate

- (void)authManager:(SFAuthenticationManager *)manager willLogoutUser:(SFUserAccount *)user {
    [self removeSharedInstanceForUserAccount:user];
}

@end
