// swift-tools-version: 6.0
import PackageDescription

let pkgRoot = Context.packageDirectory

// Each mixed-language library uses three SPM targets:
//
//   LibraryNameObjC   — ObjC-only target (.m + .h files from Classes/).
//   LibraryNameSwift  — Swift-only target. Imports LibraryNameObjC and has access
//                       to the hand-written ObjC bridge stub.
//   LibraryName       — Thin wrapper Swift target. @_exported imports LibraryNameSwift
//                       so consumers only need: import LibraryName
//                       This is the target that the public product points at.
//
// The wrapper gives consumers the same import experience as the xcframeworks-based
// SalesforceMobileSDK-iOS-SPM package, requiring no changes to app code.
//
// SalesforceAnalytics is pure ObjC — no wrapper needed.
// SalesforceSDKCoreResources is a resource-only Swift stub target.
//
// Dependency chain:
//   SalesforceSDKCommon → SalesforceAnalytics → SalesforceSDKCore → SmartStore → MobileSync

let package = Package(
    name: "SalesforceMobileSDK",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v18),
        .visionOS(.v2),
        .macCatalyst(.v13),
        .macOS(.v10_14),
    ],
    products: [
        .library(name: "SalesforceSDKCommon",  targets: ["SalesforceSDKCommon"]),
        .library(name: "SalesforceAnalytics",  targets: ["SalesforceAnalytics"]),
        .library(name: "SalesforceSDKCore",    targets: ["SalesforceSDKCore"]),
        .library(name: "SmartStore",           targets: ["SmartStore"]),
        .library(name: "MobileSync",           targets: ["MobileSync"]),
    ],
    dependencies: [
        .package(url: "https://github.com/sqlcipher/SQLCipher.swift.git", exact: "4.15.0"),
        .package(url: "https://github.com/forcedotcom/fmdb.git",          exact: "2.7.12-sqlcipher"),
    ],
    targets: [

        // MARK: - SalesforceSDKCommon (ObjC)

        .target(
            name: "SalesforceSDKCommonObjC",
            path: "libs/SalesforceSDKCommon/SalesforceSDKCommon",
            exclude: [
                "SalesforceSDKCommon.h",
                "Info.plist",
                "include",
                "Classes/module.modulemap",
                "Classes/SalesforceSDKCommon-Swift.h",
                "Classes/SPM",
                // BEGIN_SWIFT_EXCLUDE SalesforceSDKCommon
                "Classes/Keychain/GenericPasswordItemQuery.swift",
                "Classes/Keychain/KeychainHelper.swift",
                "Classes/Keychain/KeychainItemManager.swift",
                "Classes/Keychain/SecItemOperations.swift",
                "Classes/Logger/SalesforceLogReceiver.swift",
                "Classes/Logger/SalesforceLogReceiverFactory.swift",
                // END_SWIFT_EXCLUDE SalesforceSDKCommon
            ],
            sources: ["Classes"],
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Classes/Logger"),
                .headerSearchPath("Classes/Util"),
                .headerSearchPath("Classes/Keychain"),
            ]
        ),

        // MARK: - SalesforceSDKCommon (Swift layer)

        .target(
            name: "SalesforceSDKCommonSwift",
            dependencies: ["SalesforceSDKCommonObjC"],
            path: "libs/SalesforceSDKCommon/SalesforceSDKCommon",
            sources: [
                // BEGIN_SWIFT_SOURCES SalesforceSDKCommon
                "Classes/Keychain/GenericPasswordItemQuery.swift",
                "Classes/Keychain/KeychainHelper.swift",
                "Classes/Keychain/KeychainItemManager.swift",
                "Classes/Keychain/SecItemOperations.swift",
                "Classes/Logger/SalesforceLogReceiver.swift",
                "Classes/Logger/SalesforceLogReceiverFactory.swift",
                // END_SWIFT_SOURCES SalesforceSDKCommon
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),

        // MARK: - SalesforceSDKCommon (public wrapper)

        .target(
            name: "SalesforceSDKCommon",
            dependencies: ["SalesforceSDKCommonSwift"],
            path: "libs/SalesforceSDKCommon/SalesforceSDKCommon/Classes/SPM",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),

        // MARK: - SalesforceAnalytics (pure ObjC)

        .target(
            name: "SalesforceAnalytics",
            dependencies: ["SalesforceSDKCommon"],
            path: "libs/SalesforceAnalytics/SalesforceAnalytics",
            exclude: [
                "SalesforceAnalytics.h",
                "Supporting Files",
                "include",
            ],
            sources: ["Classes"],
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Classes/Manager"),
                .headerSearchPath("Classes/Model"),
                .headerSearchPath("Classes/Store"),
                .headerSearchPath("Classes/Transform"),
                .headerSearchPath("Classes/Util"),
            ]
        ),

        // MARK: - SalesforceSDKCoreResources
        // Separate target because shared/resources/ is outside every library's path.

        .target(
            name: "SalesforceSDKCoreResources",
            path: "shared/resources",
            exclude: [
                "Images.xcassets",
                "LaunchScreen.storyboard",
            ],
            sources: ["SalesforceSDKCoreResources.swift"],
            resources: [
                .process("SalesforceSDKAssets.xcassets"),
                .copy("SalesforceSDKResources.bundle"),
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),

        // MARK: - SalesforceSDKCore (ObjC)

        .target(
            name: "SalesforceSDKCoreObjC",
            dependencies: ["SalesforceAnalytics", "SalesforceSDKCoreResources"],
            path: "libs/SalesforceSDKCore/SalesforceSDKCore",
            exclude: [
                "SalesforceSDKCore.h",
                "SalesforceSDKCore-Prefix.pch",
                "Info.plist",
                "include",
                "Classes/SalesforceSDKCore-Swift.h",
                "Classes/SalesforceSDKCoreSwiftDecls.h",
                "Classes/SPM",
                // BEGIN_SWIFT_EXCLUDE SalesforceSDKCore
                "Classes/Common/WebViewStateManager.swift",
                "Classes/Extensions/Network+WebSocket.swift",
                "Classes/Extensions/PushNotificationManager+ActionableNotifications.swift",
                "Classes/Extensions/RestClient.swift",
                "Classes/Extensions/RestClient+Blocks.swift",
                "Classes/Extensions/RestClient+WebSocket.swift",
                "Classes/Extensions/URLRequest+RestRequest.swift",
                "Classes/Extensions/URLSessionTask+RetryPolicy.swift",
                "Classes/Extensions/URLSessionWebSocketTask+WebSocketClient.swift",
                "Classes/Extensions/UserAccountManager.swift",
                "Classes/IDP/SPConfig.swift",
                "Classes/Login/DevConfig/AuthFlowTypesView.swift",
                "Classes/Login/DevConfig/BootConfigEditor.swift",
                "Classes/Login/DevConfig/DiscoveryResultEditor.swift",
                "Classes/Login/DevConfig/LoginOptionsViewController.swift",
                "Classes/Login/LoginHost/NewLoginHostView.swift",
                "Classes/Login/NativeLogin/NativeLoginManager.swift",
                "Classes/Login/NativeLogin/NativeLoginManagerInternal.swift",
                "Classes/Login/SFLoginViewController+Deep-Linking.swift",
                "Classes/Login/SFLoginViewController+QrCodeLogin.swift",
                "Classes/OAuth/AuthCoordinatorFrontdoorBridgeLoginOverride.swift",
                "Classes/OAuth/DomainDiscoveryCoordinator.swift",
                "Classes/OAuth/JwtAccessToken.swift",
                "Classes/OAuth/ScopeParser.swift",
                "Classes/PushNotification/NotificationCategoryFactory.swift",
                "Classes/PushNotification/NotificationType.swift",
                "Classes/PushNotification/PushNotificationManager.swift",
                "Classes/PushNotification/RemoteNotificationRegistering.swift",
                "Classes/RestAPI/SFAPAPI/ChatGenerationsRequestBody.swift",
                "Classes/RestAPI/SFAPAPI/ChatGenerationsResponseBody.swift",
                "Classes/RestAPI/SFAPAPI/EmbeddingsRequestBody.swift",
                "Classes/RestAPI/SFAPAPI/EmbeddingsResponseBody.swift",
                "Classes/RestAPI/SFAPAPI/FeedbackRequestBody.swift",
                "Classes/RestAPI/SFAPAPI/FeedbackResponseBody.swift",
                "Classes/RestAPI/SFAPAPI/GenerationsRequestBody.swift",
                "Classes/RestAPI/SFAPAPI/GenerationsResponseBody.swift",
                "Classes/RestAPI/SFAPAPI/SfapClient.swift",
                "Classes/RestAPI/SFAPAPI/SfapError.swift",
                "Classes/RestAPI/SFAPAPI/SfapErrorResponseBody.swift",
                "Classes/RestAPI/WebSocketClient.swift",
                "Classes/Security/BiometricAuthentication/BiometricAuthenticationManager.swift",
                "Classes/Security/BiometricAuthentication/BiometricAuthenticationManagerInternal.swift",
                "Classes/Security/CryptoUtils.swift",
                "Classes/Security/DecryptStream.swift",
                "Classes/Security/Encryptor.swift",
                "Classes/Security/EncryptStream.swift",
                "Classes/Security/ScreenLock/ScreenLockManager.swift",
                "Classes/Security/ScreenLock/ScreenLockManagerInternal.swift",
                "Classes/Security/ScreenLock/ScreenLockUIView.swift",
                "Classes/Storage/KeyValueEncryptedFileStore.swift",
                "Classes/Storage/KeyValueEncryptedFileStoreInspector.swift",
                "Classes/Storage/KeyValueEncryptedFileStoreViewController.swift",
                "Classes/Util/ColorExtension.swift",
                "Classes/Views/DevInfoViewController.swift",
                // END_SWIFT_EXCLUDE SalesforceSDKCore
            ],
            sources: ["Classes"],
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Classes/Analytics"),
                .headerSearchPath("Classes/Common"),
                .headerSearchPath("Classes/Identity"),
                .headerSearchPath("Classes/IDP"),
                .headerSearchPath("Classes/IDP/Commands"),
                .headerSearchPath("Classes/Login"),
                .headerSearchPath("Classes/Login/LoginHost"),
                .headerSearchPath("Classes/OAuth"),
                .headerSearchPath("Classes/PushNotification"),
                .headerSearchPath("Classes/RestAPI"),
                .headerSearchPath("Classes/Security"),
                .headerSearchPath("Classes/Test"),
                .headerSearchPath("Classes/URLHandlers"),
                .headerSearchPath("Classes/UserAccount"),
                .headerSearchPath("Classes/UserAccount/ViewControllers"),
                .headerSearchPath("Classes/Util"),
                .headerSearchPath("Classes/Views"),
                .unsafeFlags(["-include", "\(pkgRoot)/libs/SalesforceSDKCore/SalesforceSDKCore/SalesforceSDKCore-Prefix.pch"]),
            ],
            linkerSettings: [
                .linkedLibrary("z"),
            ]
        ),

        // MARK: - SalesforceSDKCore (Swift layer)

        .target(
            name: "SalesforceSDKCoreSwift",
            dependencies: ["SalesforceSDKCoreObjC"],
            path: "libs/SalesforceSDKCore/SalesforceSDKCore",
            sources: [
                // BEGIN_SWIFT_SOURCES SalesforceSDKCore
                "Classes/Common/WebViewStateManager.swift",
                "Classes/Extensions/Network+WebSocket.swift",
                "Classes/Extensions/PushNotificationManager+ActionableNotifications.swift",
                "Classes/Extensions/RestClient.swift",
                "Classes/Extensions/RestClient+Blocks.swift",
                "Classes/Extensions/RestClient+WebSocket.swift",
                "Classes/Extensions/URLRequest+RestRequest.swift",
                "Classes/Extensions/URLSessionTask+RetryPolicy.swift",
                "Classes/Extensions/URLSessionWebSocketTask+WebSocketClient.swift",
                "Classes/Extensions/UserAccountManager.swift",
                "Classes/IDP/SPConfig.swift",
                "Classes/Login/DevConfig/AuthFlowTypesView.swift",
                "Classes/Login/DevConfig/BootConfigEditor.swift",
                "Classes/Login/DevConfig/DiscoveryResultEditor.swift",
                "Classes/Login/DevConfig/LoginOptionsViewController.swift",
                "Classes/Login/LoginHost/NewLoginHostView.swift",
                "Classes/Login/NativeLogin/NativeLoginManager.swift",
                "Classes/Login/NativeLogin/NativeLoginManagerInternal.swift",
                "Classes/Login/SFLoginViewController+Deep-Linking.swift",
                "Classes/Login/SFLoginViewController+QrCodeLogin.swift",
                "Classes/OAuth/AuthCoordinatorFrontdoorBridgeLoginOverride.swift",
                "Classes/OAuth/DomainDiscoveryCoordinator.swift",
                "Classes/OAuth/JwtAccessToken.swift",
                "Classes/OAuth/ScopeParser.swift",
                "Classes/PushNotification/NotificationCategoryFactory.swift",
                "Classes/PushNotification/NotificationType.swift",
                "Classes/PushNotification/PushNotificationManager.swift",
                "Classes/PushNotification/RemoteNotificationRegistering.swift",
                "Classes/RestAPI/SFAPAPI/ChatGenerationsRequestBody.swift",
                "Classes/RestAPI/SFAPAPI/ChatGenerationsResponseBody.swift",
                "Classes/RestAPI/SFAPAPI/EmbeddingsRequestBody.swift",
                "Classes/RestAPI/SFAPAPI/EmbeddingsResponseBody.swift",
                "Classes/RestAPI/SFAPAPI/FeedbackRequestBody.swift",
                "Classes/RestAPI/SFAPAPI/FeedbackResponseBody.swift",
                "Classes/RestAPI/SFAPAPI/GenerationsRequestBody.swift",
                "Classes/RestAPI/SFAPAPI/GenerationsResponseBody.swift",
                "Classes/RestAPI/SFAPAPI/SfapClient.swift",
                "Classes/RestAPI/SFAPAPI/SfapError.swift",
                "Classes/RestAPI/SFAPAPI/SfapErrorResponseBody.swift",
                "Classes/RestAPI/WebSocketClient.swift",
                "Classes/Security/BiometricAuthentication/BiometricAuthenticationManager.swift",
                "Classes/Security/BiometricAuthentication/BiometricAuthenticationManagerInternal.swift",
                "Classes/Security/CryptoUtils.swift",
                "Classes/Security/DecryptStream.swift",
                "Classes/Security/Encryptor.swift",
                "Classes/Security/EncryptStream.swift",
                "Classes/Security/ScreenLock/ScreenLockManager.swift",
                "Classes/Security/ScreenLock/ScreenLockManagerInternal.swift",
                "Classes/Security/ScreenLock/ScreenLockUIView.swift",
                "Classes/Storage/KeyValueEncryptedFileStore.swift",
                "Classes/Storage/KeyValueEncryptedFileStoreInspector.swift",
                "Classes/Storage/KeyValueEncryptedFileStoreViewController.swift",
                "Classes/Util/ColorExtension.swift",
                "Classes/Views/DevInfoViewController.swift",
                // END_SWIFT_SOURCES SalesforceSDKCore
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),

        // MARK: - SalesforceSDKCore (public wrapper)

        .target(
            name: "SalesforceSDKCore",
            dependencies: ["SalesforceSDKCoreSwift"],
            path: "libs/SalesforceSDKCore/SalesforceSDKCore/Classes/SPM",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),

        // MARK: - SmartStore (ObjC)

        .target(
            name: "SmartStoreObjC",
            dependencies: [
                "SalesforceSDKCore",
                .product(name: "SQLCipher", package: "SQLCipher.swift"),
                .product(name: "FMDB",      package: "fmdb"),
            ],
            path: "libs/SmartStore/SmartStore",
            exclude: [
                "SmartStore.h",
                "SmartStore-Prefix.pch",
                "Info.plist",
                "include",
                "Classes/module.modulemap",
                "Classes/SmartStore-Swift.h",
                "Classes/SPM",
                // BEGIN_SWIFT_EXCLUDE SmartStore
                "Classes/Extensions/SmartStore.swift",
                // END_SWIFT_EXCLUDE SmartStore
            ],
            sources: ["Classes"],
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Classes"),
                .headerSearchPath("Classes/Extensions"),
                .unsafeFlags(["-include", "\(pkgRoot)/libs/SmartStore/SmartStore/SmartStore-Prefix.pch"]),
            ]
        ),

        // MARK: - SmartStore (Swift layer)

        .target(
            name: "SmartStoreSwift",
            dependencies: ["SmartStoreObjC"],
            path: "libs/SmartStore/SmartStore",
            sources: [
                // BEGIN_SWIFT_SOURCES SmartStore
                "Classes/Extensions/SmartStore.swift",
                // END_SWIFT_SOURCES SmartStore
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),

        // MARK: - SmartStore (public wrapper)

        .target(
            name: "SmartStore",
            dependencies: ["SmartStoreSwift"],
            path: "libs/SmartStore/SmartStore/Classes/SPM",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),

        // MARK: - MobileSync (ObjC)

        .target(
            name: "MobileSyncObjC",
            dependencies: ["SmartStore"],
            path: "libs/MobileSync/MobileSync",
            exclude: [
                "MobileSync.h",
                "MobileSync-Prefix.pch",
                "Info.plist",
                "include",
                "Classes/CocoaPods.modulemap",
                "Classes/MobileSync-Swift.h",
                "Classes/SPM",
                // BEGIN_SWIFT_EXCLUDE MobileSync
                "Classes/BatchSyncUpTarget.swift",
                "Classes/CollectionSyncUpTarget.swift",
                "Classes/Extensions/MobileSync.swift",
                "Classes/SyncTarget.swift",
                "Classes/Target/BriefcaseSyncDownTarget.swift",
                "Classes/Util/BriefcaseObjectInfo.swift",
                "Classes/Util/CompositeRequestHelper.swift",
                // END_SWIFT_EXCLUDE MobileSync
            ],
            sources: ["Classes"],
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
            ],
            publicHeadersPath: "include",
            cSettings: [
                .define("SWIFT_PACKAGE"),
                .headerSearchPath("Classes"),
                .headerSearchPath("Classes/Config"),
                .headerSearchPath("Classes/Extensions"),
                .headerSearchPath("Classes/Manager"),
                .headerSearchPath("Classes/Model"),
                .headerSearchPath("Classes/Target"),
                .headerSearchPath("Classes/Util"),
                .unsafeFlags(["-include", "\(pkgRoot)/libs/MobileSync/MobileSync/MobileSync-Prefix.pch"]),
            ]
        ),

        // MARK: - MobileSync (Swift layer)

        .target(
            name: "MobileSyncSwift",
            dependencies: ["MobileSyncObjC"],
            path: "libs/MobileSync/MobileSync",
            sources: [
                // BEGIN_SWIFT_SOURCES MobileSync
                "Classes/BatchSyncUpTarget.swift",
                "Classes/CollectionSyncUpTarget.swift",
                "Classes/Extensions/MobileSync.swift",
                "Classes/SyncTarget.swift",
                "Classes/Target/BriefcaseSyncDownTarget.swift",
                "Classes/Util/BriefcaseObjectInfo.swift",
                "Classes/Util/CompositeRequestHelper.swift",
                // END_SWIFT_SOURCES MobileSync
            ],
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),

        // MARK: - MobileSync (public wrapper)

        .target(
            name: "MobileSync",
            dependencies: ["MobileSyncSwift"],
            path: "libs/MobileSync/MobileSync/Classes/SPM",
            swiftSettings: [
                .swiftLanguageMode(.v5),
            ]
        ),
    ]
)
