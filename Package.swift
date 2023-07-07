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
	     checksum: "97f2e87a70d431f4a99e429f65a4b3508373e7717b0fc4a18701dd534d7e5934",
         ),
        .binaryTarget(
            name: "SalesforceSDKCommon",
	    url: "http://localhost:8080/SalesforceSDKCommon.xcframework.zip",
	    checksum: "e2bc28f56984e1b6dde9a0f9dbf00fc27fd39346000b3cddb3b9485d65f897b1",
        ),
        .binaryTarget(
            name: "SalesforceSDKCore",
	    url: "http://localhost:8080/SalesforceSDKCore.xcframework.zip",
	    checksum: "65c70e0008d9c762915a88eeb3faa917c9c0d1d544b9645bc606a06083420f0f",
        ),
        .binaryTarget(
            name: "SmartStore",
	    url: "http://localhost:8080/SmartStore.xcframework.zip",
	    checksum: "a91a0a6df73d333da5bc7e8757213f3907adee4cf42117f9ac91f8ea727d2160",
        ),
        .binaryTarget(
            name: "MobileSync",
	    url: "http://localhost:8080/MobileSync.xcframework.zip",
	    checksum: "9212dc012f9895ba64096cd89bdf14d3f992e512ebee3bf7f16d8b09b3e9dc3f",
        )
    ],
    swiftLanguageVersions: [.v5]
)