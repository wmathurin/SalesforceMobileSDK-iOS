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
             url: "http://localhost:8080/SalesforceAnalytics.xcframework.zip",
	     checksum: "1b848bafd193e9e6f9f0017d216008131c5ff500a2355fc9424dff90918c0f7e" // SalesforceAnalytics
         ),
        .binaryTarget(
            name: "SalesforceSDKCommon",
	    url: "http://localhost:8080/SalesforceSDKCommon.xcframework.zip",
	    checksum: "e728920bf163e06b69c1ef4ad98401611384ca3f8c6bbb2d082e46f94e046353" // SalesforceSDKCommon
        ),
        .binaryTarget(
            name: "SalesforceSDKCore",
	    url: "http://localhost:8080/SalesforceSDKCore.xcframework.zip",
	    checksum: "8fd8804fcb8c7d46665a8be53fce96d46f3d51dcd95a80e477b82d3b741b55a3" // SalesforceSDKCore
        ),
        .binaryTarget(
            name: "SmartStore",
	    url: "http://localhost:8080/SmartStore.xcframework.zip",
	    checksum: "957f3f0844678c8a239ceec44c91ffb40d8fa8e9c7ba569fca08823d746292ea" // SmartStore
        ),
        .binaryTarget(
            name: "MobileSync",
	    url: "http://localhost:8080/MobileSync.xcframework.zip",
	    checksum: "2236ef909938874f3ac1c30177eab17b7bfa486d1493d5819eaa81750b3477a8" // MobileSync
        )
    ],
    swiftLanguageVersions: [.v5]
)