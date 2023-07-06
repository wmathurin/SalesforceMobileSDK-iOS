// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "SalesforceMobileSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "SalesforceAnalytics",
            targets: ["SalesforceAnalytics"]
        ),
        .library(
            name: "SalesforceSDKCommon",
            targets: ["SalesforceSDKCommon"]
        ),
        .library(
            name: "SalesforceSDKCore",
            targets: ["SalesforceSDKCore"]
        ),
        .library(
            name: "SmartStore",
            targets: ["SmartStore"]
        ),
        .library(
            name: "MobileSync",
            targets: ["MobileSync"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
             name: "SalesforceAnalytics",
             path: "archives/SalesforceAnalytics.xcframework"
         ),
        .binaryTarget(
            name: "SalesforceSDKCommon",
            path: "archives/SalesforceSDKCommon.xcframework"
        ),
        .binaryTarget(
            name: "SalesforceSDKCore",
            path: "archives/SalesforceSDKCore.xcframework"
        ),
        .binaryTarget(
            name: "SmartStore",
            path: "archives/SmartStore.xcframework"
        ),
        .binaryTarget(
            name: "MobileSync",
            path: "archives/MobileSync.xcframework"	    
        )
    ],
    swiftLanguageVersions: [.v5]
)