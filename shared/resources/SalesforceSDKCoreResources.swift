import Foundation

/// Exposes the SPM resource bundle for SalesforceSDKCoreResources to ObjC callers.
@objc public class SalesforceSDKCoreResourcesBundle: NSObject {
    /// The bundle produced by SPM for the SalesforceSDKCoreResources target.
    /// Under SPM this is `SalesforceMobileSDK_SalesforceSDKCoreResources.bundle`;
    /// callers should look inside it for nested resource bundles.
    @objc public static var bundle: Bundle { Bundle.module }
}
