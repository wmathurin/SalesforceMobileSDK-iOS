// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "SalesforceMobileSDK",
    platforms: [
        .iOS(.v12),.watchOS(.v5)
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
            path: "libs/SalesforceSDKCommon",
            dependencies: ["SalesforceAnalytics"]
        ),
        .target(
            name: "SalesforceSDKCore",
            path: "libs/SalesforceSDKCore"
            dependencies: ["SalesforceSDKCommon"]
        ),
        .target(
            name: "SmartStore",
            path: "libs/SmartStore",
            dependencies: ["SalesforceSDKCore"]
        ),
        .target(
            name: "MobileSync",
            path: "libs/MobileSync"
            dependencies: ["SmartStore"]
        ),
    ],
    swiftLanguageVersions: [.v5_0]
)