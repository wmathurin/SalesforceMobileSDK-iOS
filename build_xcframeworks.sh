#!/bin/bash

#set -x

function header() {
    local SPACER="---------------------------------------------------------------------------"
    echo -e "\n\n$SPACER\n    $1\n$SPACER\n"
}

function processLib() {
    local lib=$1
    
    header "Building iOS archive for $lib"
    xcodebuild archive \
        -workspace SalesforceMobileSDK.xcworkspace \
        -scheme $lib \
        -destination "generic/platform=iOS" \
        -archivePath ./archives/$lib-iOS \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    header "Building iOS simulator archive for $lib"
    xcodebuild archive \
        -workspace SalesforceMobileSDK.xcworkspace \
        -scheme $lib \
        -destination "generic/platform=iOS Simulator" \
        -archivePath ./archives/$lib-Sim \
        SKIP_INSTALL=NO \
        BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    header "Building xcframework for $lib"
    xcodebuild -create-xcframework \
        -framework ./archives/$lib-iOS.xcarchive/Products/Library/Frameworks/$lib.framework \
        -framework ./archives/$lib-Sim.xcarchive/Products/Library/Frameworks/$lib.framework \
        -output ./archives/$lib.xcframework

    header "Zipping xcframework for $lib"
    cd archives
    zip $lib.xcframework.zip $lib.xcframework -r
    cd ..

    header "Cleaning up intermediate files for $lib"
    rm -rf ./archives/$lib-iOS.xcarchive
    rm -rf ./archives/$lib-Sim.xcarchive
    rm -rf ./archives/$lib.xcframework

    header "Updating checksum in Package.swift"
    local checksum=`swift package compute-checksum ./archives/$lib.xcframework.zip`
    echo "checksum for $lib ==> $checksum"
    gsed -i "s/checksum: \"[^\"]*\" \/\/ ${lib}/checksum: \"${checksum}\" \/\/ ${lib}/g" ./Package.swift
}


for lib in 'SalesforceSDKCommon' 'SalesforceAnalytics' 'SalesforceSDKCore' 'SmartStore' 'MobileSync'
do
    processLib $lib
done
