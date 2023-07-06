// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "SalesforceMobileSDK",
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
        .target(
            name: "SalesforceSDKCommon",
            dependencies: ["SalesforceAnalytics"],
            path: "archives/SalesforceSDKCommon.xcframework"
        ),
        .target(
            name: "SalesforceSDKCore",
            dependencies: ["SalesforceSDKCommon"],
            path: "archives/SalesforceSDKCore.xcframework"
        ),
        .target(
            name: "SmartStore",
            dependencies: ["SalesforceSDKCore"],
            path: "archives/SmartStore.xcframework"
        ),
        .target(
            name: "MobileSync",
            dependencies: ["SmartStore"],
            path: "archives/MobileSync.xcframework"	    
        )
    ],
    swiftLanguageVersions: [.v5]
)