//
//  SFSDKLoginHostStorage.m
//  SalesforceSDKCore
//
//  Created by Jean Bovet on 9/22/11.
//  Copyright (c) 2011 Salesforce.com. All rights reserved.
//

#import "SFSDKLoginHostStorage.h"
#import "SFSDKLoginHost.h"
#import "SFSDKResourceUtils.h"
#import "SFManagedPreferences.h"

@interface SFSDKLoginHostStorage ()

@property (nonatomic, strong) NSMutableArray *loginHostList;

@end

// Key under which the list of login hosts will be stored in the user defaults.
static NSString * const SFSDKLoginHostList = @"ChatterLoginHostListPrefs";

// Key for the host.
static NSString * const SFSDKLoginHostKey = @"ChatterLoginHostKey";

// Key for the name.
static NSString * const SFSDKLoginHostNameKey = @"ChatterLoginHostNameKey";

@implementation SFSDKLoginHostStorage

@synthesize loginHostList = _loginHostList;

+ (SFSDKLoginHostStorage *)sharedInstance {
    static SFSDKLoginHostStorage *instance = nil;
    if (!instance) {
        instance = [[self alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.loginHostList = [NSMutableArray array];
        
        // Load from managed preferences (e.g. MDM).
        SFManagedPreferences *managedPreferences = [SFManagedPreferences sharedPreferences];
        if (managedPreferences.hasManagedPreferences) {
            NSArray *hostLabels = managedPreferences.loginHostLabels;
            [managedPreferences.loginHosts enumerateObjectsUsingBlock:^(NSString *loginHost, NSUInteger idx, BOOL *stop) {
                NSString *hostLabel = hostLabels.count > idx ? hostLabels[idx] : loginHost;
                [self.loginHostList addObject:[SFSDKLoginHost hostWithName:hostLabel host:loginHost deletable:NO]];
            }];
        }
        
        // Add the Production and Sandbox login hosts are defined. These two items cannot be deleted.
        [self.loginHostList addObject:[SFSDKLoginHost hostWithName:[SFSDKResourceUtils localizedString:@"loginServerProduction"]
                                                                host:@"login.salesforce.com"
                                                           deletable:NO]];
        [self.loginHostList addObject:[SFSDKLoginHost hostWithName:[SFSDKResourceUtils localizedString:@"loginServerSandbox"]
                                                                host:@"test.salesforce.com"
                                                           deletable:NO]];
        
        // Load from the user defaults
        NSArray *persistedList = [[NSUserDefaults standardUserDefaults] objectForKey:SFSDKLoginHostList];
        if (persistedList) {
            for (NSDictionary *dic in persistedList) {
                [self.loginHostList addObject:[SFSDKLoginHost hostWithName:[dic objectForKey:SFSDKLoginHostNameKey]
                                                                        host:[dic objectForKey:SFSDKLoginHostKey]
                                                                   deletable:YES]];
            }
        }
    }
    
    return self;
}

- (void)save {    
    NSMutableArray *persistedList = [NSMutableArray arrayWithCapacity:10];
    for (SFSDKLoginHost *host in self.loginHostList) {
        if (host.isDeletable) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            [dic setObject:host.name forKey:SFSDKLoginHostNameKey];
            [dic setObject:host.host forKey:SFSDKLoginHostKey];
            [persistedList addObject:dic];
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:persistedList forKey:SFSDKLoginHostList];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addLoginHost:(SFSDKLoginHost *)loginHost {
    [self.loginHostList addObject:loginHost];
    [self save];
}

- (void)removeLoginHostAtIndex:(NSUInteger)index {
    [self.loginHostList removeObjectAtIndex:index];
    [self save];
}

- (NSUInteger)indexOfLoginHost:(SFSDKLoginHost *)host{
    if ([self.loginHostList containsObject:host]) {
        return [self.loginHostList indexOfObject:host];
    }
    return NSNotFound;
}

- (SFSDKLoginHost *)loginHostAtIndex:(NSUInteger)index {
    return [self.loginHostList objectAtIndex:index];
}

- (SFSDKLoginHost *)loginHostForHostAddress:(NSString *)hostAddress {
    for (SFSDKLoginHost *host in self.loginHostList) {
        if ([host.host isEqualToString:hostAddress]) {
            return host;
        }
    }
    return nil;
}

- (void)removeAllLoginHosts {
    [self.loginHostList removeObjectsInRange:NSMakeRange(2, [self.loginHostList count]-2)];
}

- (NSUInteger)numberOfLoginHosts {
    return [self.loginHostList count];
}

@end
