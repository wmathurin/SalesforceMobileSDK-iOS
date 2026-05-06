/*
 SalesforceSDKCoreSwiftDecls.h — Minimal ObjC type stubs for Swift-defined classes.

 SPM generates module maps without a SalesforceSDKCore.Swift submodule, so the Swift
 importer doesn't see SalesforceSDKCore-Swift.h when processing the ObjC module.
 Properties using forward-declared types (SFSDKNotificationType etc.) are silently dropped.

 Guarded by __swift__ (set only by the Swift compiler when importing ObjC modules)
 so the ObjC compiler never sees these stubs, avoiding duplicate-definition errors.

 Each stub uses __attribute__((swift_name("SwiftName"))) so the Swift importer treats
 e.g. SFSDKNotificationType as the same type as Swift's `NotificationType`. This mirrors
 what SWIFT_CLASS_NAMED does in the real SalesforceSDKCore-Swift.h.
*/
#if defined(__swift__) && defined(SWIFT_PACKAGE)

#import <Foundation/Foundation.h>

__attribute__((swift_name("NotificationType")))
__attribute__((objc_subclassing_restricted))
@interface SFSDKNotificationType : NSObject
@end

__attribute__((swift_name("DomainDiscoveryResult")))
__attribute__((objc_subclassing_restricted))
@interface SFDomainDiscoveryResult : NSObject
@property (nonatomic, readonly, copy) NSString * _Nonnull loginHint;
@property (nonatomic, readonly, copy) NSString * _Nonnull myDomain;
@end

__attribute__((swift_name("BiometricAuthenticationManager")))
@protocol SFBiometricAuthenticationManager
@property (nonatomic, readonly) BOOL locked;
@end

#endif /* __swift__ && SWIFT_PACKAGE */
