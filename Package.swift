// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SalesforceMobileSDK",
    platforms: [
        .iOS(.v13),
        .watchOS(.v7),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "SalesforceSDKCommon",
            targets: ["SalesforceSDKCommon-ObjC", "SalesforceSDKCommon-Swift"]
        ),
        .library(
            name: "SalesforceAnalytics",
            targets: ["SalesforceAnalytics-ObjC"]
        ),
        .library(
            name: "SalesforceSDKCore",
            targets: ["SalesforceSDKCore-ObjC", "SalesforceSDKCore-Swift"]
        ),
        .library(
            name: "SmartStore",
            targets: ["SmartStore-ObjC", "SmartStore-Swift"]
        ),
        .library(
            name: "MobileSync",
            targets: ["MobileSync-ObjC", "MobileSync-Swift"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "SQLCipher",
            path: "external/ThirdPartyDependencies/sqlcipher/SQLCipher.xcframework"
        ),
        .target(
            name: "SalesforceSDKCommon-ObjC",
            path: "libs/SalesforceSDKCommon/SalesforceSDKCommon",
            exclude: ["Classes/Keychain/KeychainManager.swift"],
            publicHeadersPath: "include"
        ),
        .target(
            name: "SalesforceSDKCommon-Swift",
            dependencies: ["SalesforceSDKCommon-ObjC"],
            path: "libs/SalesforceSDKCommon/SalesforceSDKCommon",
            sources: ["Classes/Keychain/KeychainManager.swift"]
        ),
        .target(
            name: "SalesforceAnalytics-ObjC",
            dependencies: ["SalesforceSDKCommon-ObjC"],
            path: "libs/SalesforceAnalytics/SalesforceAnalytics"
        ),
        .target(
            name: "SalesforceSDKCore-ObjC",
            dependencies: ["SalesforceAnalytics-ObjC"],
            path: "libs/SalesforceSDKCore/SalesforceSDKCore",
            exclude: [
                "Classes/Storage/KeyValueEncryptedFileStoreViewController.swift",
                "Classes/Storage/KeyValueEncryptedFileStore.swift",
                "Classes/Storage/KeyValueEncryptedFileStoreInspector.swift",
                "Classes/Extensions/PushNotificationManager.swift",
                "Classes/Extensions/RestClient.swift",
                "Classes/Extensions/UserAccountManager.swift"
            ],
            resources: [
                .process("../../../shared/resources/SalesforceSDKAssets.xcassets"),
                .process("../../../shared/resources/SalesforceSDKResources.bundle")
            ]
        ),
        .target(
            name: "SalesforceSDKCore-Swift",
            dependencies: ["SalesforceSDKCore-ObjC"],
            path: "libs/SalesforceSDKCore/SalesforceSDKCore",
            sources: [
                "Classes/Storage/KeyValueEncryptedFileStoreViewController.swift",
                "Classes/Storage/KeyValueEncryptedFileStore.swift",
                "Classes/Storage/KeyValueEncryptedFileStoreInspector.swift",
                "Classes/Extensions/PushNotificationManager.swift",
                "Classes/Extensions/RestClient.swift",
                "Classes/Extensions/UserAccountManager.swift"
            ]
        ),
        .target(
            name: "SmartStore-ObjC",
            dependencies: ["SalesforceSDKCore-ObjC", "SQLCipher"],
            path: "libs/SmartStore/SmartStore",
            exclude: ["Classes/Extensions/SmartStore.swift"]
        ),
        .target(
            name: "SmartStore-Swift",
            dependencies: ["SmartStore-ObjC"],            
            path: "libs/SmartStore/SmartStore",
            sources: ["Classes/Extensions/SmartStore.swift"]
        ),
        .target(
            name: "MobileSync-ObjC",
            dependencies: ["SmartStore-ObjC"],
            path: "libs/MobileSync/MobileSync",
            exclude: ["Classes/Extensions/MobileSync.swift"]
        ),
        .target(
            name: "MobileSync-Swift",
            dependencies: ["MobileSync-ObjC"],
            path: "libs/MobileSync/MobileSync",
            sources: ["Classes/Extensions/MobileSync.swift"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
