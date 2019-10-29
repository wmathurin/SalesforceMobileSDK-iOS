// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SalesforceMobileSDK",
    platforms: [
        .iOS(.v12),
        .watchOS(.v5)
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
        .target(
            name: "SalesforceAnalytics",
            path: "libs/SalesforceAnalytics"
        ),
        .target(
            name: "SalesforceSDKCommon",
            dependencies: ["SalesforceAnalytics"],
            path: "libs/SalesforceSDKCommon"
        ),
        .target(
            name: "SalesforceSDKCore",
            dependencies: ["SalesforceSDKCommon"],
            path: "libs/SalesforceSDKCore"
        ),
        .target(
            name: "SmartStore",
            dependencies: ["SalesforceSDKCore"],
            path: "libs/SmartStore"
        ),
        .target(
            name: "MobileSync",
            dependencies: ["SmartStore"],
            path: "libs/MobileSync"
        )
    ],
    swiftLanguageVersions: [.v5]
)