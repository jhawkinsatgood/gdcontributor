#!/bin/bash

# Based on some of the msdk/platform/ios/build_apps.sh script.

IOS_SDK_VERSION=''  #7.0

find . -type d -name '*.xcodeproj' | while read XCODE_PROJ;
do
    echo "$XCODE_PROJ"

    XCODE_PROJ_PATH="$(dirname "${XCODE_PROJ}")"
    XCODE_PROJ_NAME="$(basename "${XCODE_PROJ}")"
    APP_NAME=${XCODE_PROJ_NAME%.*}
    
    xcodebuild \
        -project "${XCODE_PROJ}" \
        -sdk iphoneos${IOS_SDK_VERSION} \
        -configuration Release CODE_SIGN_IDENTITY="iPhone Distribution" \
        -scheme "${APP_NAME}" \
        -archivePath "${XCODE_PROJ_PATH}/${APP_NAME}/" \
        archive
    
    echo '++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
    
    xcodebuild \
        -exportArchive -archivePath "${XCODE_PROJ_PATH}/${APP_NAME}.xcarchive" \
        -exportPath "${XCODE_PROJ_PATH}/${APP_NAME}.ipa" \
        -exportProvisioningProfile "Good Dynamics Apps Enterprise Distribution"
done
