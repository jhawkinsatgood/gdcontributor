#!/bin/sh

# Sample application build and rebuild script

# Copyright (c) 2015 Good Technology Corporation
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Set ORGANISATION_NAME to the name of your organisation. Spaces are not allowed.
export ORGANISATION_NAME=GoodTechnologyExample

# Set GD_PLUGIN_DIR to the path of where you extracted the GD PhoneGap Plugin
# download.
export GD_PLUGIN_DIR=""

# Set either of these to the empty string to switch off addition of the
# platform.
export CREATE_ANDROID="yes"
export CREATE_IOS="yes"

# You can set GD_ANDROID_DIR here, in case the script cannot work it out. Set it
# to the location of your installation of the Good Dynamics SDK for Android,
# specifically the path of your dynamics_sdk/ directory.
export GD_ANDROID_DIR=''

export APP_NAME="AppKinetics Workflow"
export APP_ID_PREFIX="com.good.example.contributor.jhawkins"
export APP_ID="${APP_ID_PREFIX}.appkineticsworkflow"

function setAndroidDir()
{
    SAVE_DIR="$PWD"
    WHICH_ANDROID="which android"
    ANDROID_PATH=`$WHICH_ANDROID`
    if test -z "$ANDROID_PATH";
    then
        echo "Could not find android by \"$WHICH_ANDROID\"."
    else
        # Go up to the Android SDK and then down to the default installation
        # sub-directory of GD.
        ANDROID_PATH=`dirname "$ANDROID_PATH"`
        ANDROID_PATH=`dirname "$ANDROID_PATH"`
        ANDROID_PATH="${ANDROID_PATH}/extras/good/"
        cd "$ANDROID_PATH"
        if test -d dynamics_sdk;
        then
            GD_ANDROID_DIR="${PWD}/dynamics_sdk"
        else
            echo \
                "Could not find GD SDK for Android installation under "\
                "\"${ANDROID_PATH}\" directory."
        fi
    fi
    cd "$SAVE_DIR"
}

function syncWWW()
{
    SYNC_FROM="$1"
    shift
    SYNC_TO="$1"
    shift

    # Create any directories that exist in the source, but not in the target.
    find "$SYNC_FROM" -not -path '*/plugins/*' -type d \
        -exec test '!' -d "$SYNC_TO/"{} \; \
        -exec mkdir "$SYNC_TO/"{} \; \
        -print

    # Copy any files that are newer than the root. The calling code has to set
    # the modification time of the root so that there is no wasteful copying.
    find "$SYNC_FROM" -not -path '*/plugins/*' -type f \
        '(' -newer "$SYNC_FROM" -or -exec test '!' -f "$SYNC_TO/"{} \; ')' \
        -exec cp {} "$SYNC_TO/"{} \; \
        -print
}

function rebuild()
{
    SAVE_DIR="$PWD"
    DID=""
    # Change to the project directory, if necessary.
    # If it's not here, assume we are already in the project directory.
    if test -d "$APP_NAME" ;
    then
        cd "$APP_NAME"
    fi

    # Uncomment the following to remove and re-add the code plugin
    cordova plugin remove com.good.example.contributor.jhawkins
    cordova plugin add ../../src/com.good.example.contributor.jhawkins

    # Uncomment the following to refresh the source from the original.
    #echo "Reloading www/ from original."
    #cp -r "../../src/${APP_ID}/www/" www/

    # Save the list of plugins, and make a temporary copy of the installed
    # plugins themselves.
    local PLUGINS_TMP="$TMPDIR"
    if test -z "$PLUGINS_TMP" ;
    then
        $PLUGINS_TMP='/tmp'
    fi
    PLUGINS_TMP="${PLUGINS_TMP}/gdcontributorplugins$$/"
    cp -r "plugins" "$PLUGINS_TMP"

    # Uncomment the following to remove and re-add the file plugin, which can
    # resolve some issues.
    #cordova plugin remove org.apache.cordova.file
    #cordova plugin add org.apache.cordova.file --searchpath "$PLUGINS_TMP"
    
    # Remove temporary copy of the plugins.
    rm -rf "$PLUGINS_TMP"

    if test -d platforms/android ;
    then
        echo "Synchronising asset files for Android"
        syncWWW www platforms/android/assets
        DID="${DID} Android"
    fi
    if test -d platforms/ios ;
    then
        echo "Synchronising asset files for iOS"
        syncWWW www platforms/ios
        DID="${DID} iOS"
    fi
    if test -z "$DID" ;
    then
        echo "Nothing to rebuild"
    else
        # Set the modification time of the www/ directory to prevent wasteful
        # copying.
        touch www
    fi
    cd "$SAVE_DIR"
}
# rebuild()

function create()
{
    # Create a cordova project and copy in the sample application source.
    cordova create "$APP_NAME" "$APP_ID" "$APP_NAME" \
        --copy-from "../src/${APP_ID}/www/"

    # Change to the new project directory.
    cd "$APP_NAME"
    
    # Add the required platforms.
    #
    # An error like the following might be encountered here if the files in the
    # demo code plugin are read-only.
    # cp: copyFileSync: could not write to dest file (code=EACCES):
    # some/path/gdcontributor/samples/AppKinetics Workflow/platforms/android/
    # assets/www/css/com.good.example.contributor.jhawkins/demo/mainpage.css
    #
    # An error like the following might be encountered here if the files in the
    # --copy-from directory are read-only.
    # cp: platforms/ios/www/index.html: Permission denied
    #
    if test -n "$CREATE_ANDROID" ;
    then
        cordova platform add android
    fi
    if test -n "$CREATE_IOS" ;
    then
        cordova platform add ios
    fi
    # From this point onwards, the presence of platform sub-directories is used
    # to determine the need to do processing for each platform.

    # Add some typical plugins.
    # Use these when connected to the Internet
    cordova plugin add org.apache.cordova.device \
                       org.apache.cordova.file \
                       org.apache.cordova.console
                       
    # Append the following line after a backslash if you are not connected to
    # the Internet. Cordova will then add the plugins from your local copies.
    # --searchpath "/path/to/an/existing/Cordova/project/plugins/"
    
    # Add the demo code, which is provided as a plugin.
    cordova plugin add ../../src/com.good.example.contributor.jhawkins
    
    # Save the project directory
    export PROJECT_DIR="$PWD"

    # Save the list of plugins, and make a temporary copy of the installed
    # plugins themselves.
    local PLUGINS=`cordova plugin list | cut -f 1 -d ' '`
    local PLUGINS_TMP="$TMPDIR"
    if test -z "$PLUGINS_TMP" ;
    then
        $PLUGINS_TMP='/tmp'
    fi
    PLUGINS_TMP="${PLUGINS_TMP}/gdcontributorplugins$$/"
    cp -r "$PROJECT_DIR/plugins" "$PLUGINS_TMP"

    # Change back to the original directory in case any paths were specified
    # relatively.
    cd ..
    
    # Something bad seems to happen if we do android then iOS. So we do iOS then
    # android.
    if test -d "${APP_NAME}/platforms/ios" ;
    then
        # Enable GD for iOS
        cd "${GD_PLUGIN_DIR}/iOS/SampleApplications/UpdateApp-Cordova/"
        ENABLESH='./FIXEDgdEnableApp.sh'
        if test '!' -f "$ENABLESH" ;
        then
            echo 'No FIXED script for iOS. Assuming fixed version was installed.'
            ENABLESH='./gdEnableApp.sh'
        fi
        bash "$ENABLESH" -c "$APP_ID_PREFIX" -g "$ORGANISATION_NAME" \
            -i "$APP_ID" -p "${PROJECT_DIR}/platforms/ios/"
        
        cd "$PROJECT_DIR"

        echo "Fixing deployment target, if necessary."
        sed -i \
            -e 's/IPHONEOS_DEPLOYMENT_TARGET = 5\.0;/IPHONEOS_DEPLOYMENT_TARGET = 6.0;/g' \
            "platforms/ios/${APP_NAME}.xcodeproj/project.pbxproj"

        # Switch back to initial directory
        cd ..
    fi
    
    if test -d "${APP_NAME}/platforms/android" ;
    then
        # Enable GD for Android
        cd "${GD_PLUGIN_DIR}/Android/GDCordova/"
    
        bash ./FIXEDgdEnableApp.sh \
            -n "$APP_ID" \
            -g "$ORGANISATION_NAME" \
            -p "${PROJECT_DIR}/platforms/android/"

        # Fix up the project files created by the enable script.
        cd "${PROJECT_DIR}"

        cat <<'MANIFEST.NOTE'

Sorry, this script does not insert the GDApplicationVersion meta-data tag in the
AndroidManifest.xml file. Best practice is to insert a tag like the following in
the <application> item.

        <meta-data
            android:name="GDApplicationVersion"
            android:value ="1.0.0.0" />

MANIFEST.NOTE

        # Switch back to initial directory
        cd ..
    fi

    # Remove temporary copy of the plugins.
    rm -rf "$PLUGINS_TMP"
}
# create()

if test $# '>' 0;
then
    GD_PLUGIN_DIR="$1"
    shift
fi

if test '!' -d "$APP_NAME" && test "`basename \"$PWD\"`" '!=' "$APP_NAME";
then
    # We will be creating the project.
    ERROR=''

    # Try to work out the GD SDK for Android install directory, if it's needed
    # and if it hasn't been specified explicitly.
    if test -n "$CREATE_ANDROID" -a -z "$GD_ANDROID_DIR";
    then
        setAndroidDir
    fi
    if test -z "$GD_ANDROID_DIR" -a -n "$CREATE_ANDROID";
    then
        ERROR="error"
        echo "GD_ANDROID_DIR not set manually or automatically."
    fi
    
    if test '!' -d "$GD_PLUGIN_DIR";
    then
        ERROR="error"
        cat <<GD_PLUGIN_DIR.BLANK
GD_PLUGIN_DIR "${GD_PLUGIN_DIR}" does not exist or is not a directory.
It should be the path to the directory in which you extracted the GD PhoneGap
Plugin download. You can set it at the top of the script or put it as the first
and only command line parameter.
GD_PLUGIN_DIR.BLANK
    fi
    
    if test -z "$ERROR";
    then
        create
    else
        # One or more error messages will have been printed already.
        exit 1
    fi
else
    rebuild
fi
