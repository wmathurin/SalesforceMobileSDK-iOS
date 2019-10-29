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
            path: "libs/SalesforceAnalytics/SalesforceAnalytics"
        ),
        .target(
            name: "SalesforceSDKCommon",
            dependencies: ["SalesforceAnalytics"],
            path: "libs/SalesforceSDKCommon/SalesforceSDKCommon"
        ),
        .target(
            name: "SalesforceSDKCore",
            dependencies: ["SalesforceSDKCommon"],
            path: "libs/SalesforceSDKCore/SalesforceSDKCore",
            exclude: ["Classes/Extensions/RestClient.swift"]
        ),
        .target(
            name: "SmartStore",
            dependencies: ["SalesforceSDKCore"],
            path: "libs/SmartStore/SmartStore",
            exclude: ["Classes/Extensions/SmartStore.swift"]
        ),
        .target(
            name: "MobileSync",
            dependencies: ["SmartStore"],
            path: "libs/MobileSync/MobileSync",
            exclude: ["Classes/Extensions/MobileSync.swift"]
        )
    ],
    swiftLanguageVersions: [.v5]
)