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
    #cordova plugin remove com.good.example.contributor.jhawkins
    #cordova plugin add ../../src/com.good.example.contributor.jhawkins

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
    cordova plugin remove org.apache.cordova.file
    cordova plugin add org.apache.cordova.file --searchpath "$PLUGINS_TMP"
    
    # Remove temporary copy of the plugins.
    rm -rf "$PLUGINS_TMP"

    if test -d platforms/android ;
    then
        echo "Synchronising asset files for Android"
        cp -R www/ platforms/android/assets/www/
        DID="${DID} Android"
    fi
    if test -d platforms/ios ;
    then
        echo "Synchronising asset files for iOS"
        cp -R www/ platforms/ios/www/
        DID="${DID} iOS"
    fi
    if test -z "$DID" ;
    then
        echo "Nothing to rebuild"
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
    
    # Add the required platforms.
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
    
    if test -d "${APP_NAME}/platforms/android" ;
    then
        # Enable GD for Android
        cd "${GD_PLUGIN_DIR}/Android/GDCordova3x/"
    
        bash ./FIXEDgdEnableApp.sh \
            -n "$APP_ID_PREFIX" \
            -g "$ORGANISATION_NAME" \
            -i "$APP_ID" \
            -p "${PROJECT_DIR}/platforms/android/"

        # Fix up the project files created by the enable script.
        cd "${PROJECT_DIR}"

        # Remove and add back all the plugins, from the temporary copy.
        cordova plugin rm $PLUGINS
        cordova plugin add $PLUGINS --searchpath "$PLUGINS_TMP"

        echo "Fixing project.properties file."
        # Enable Android manifest merging
        echo 'manifestmerger.enabled=true' >> platforms/android/project.properties
        
        echo "Replacing project duplicate of the GD SDK for Android."
        rm -r platforms/android/gd
        mkdir platforms/android/com.good.gd
        cp -r "$GD_ANDROID_DIR" platforms/android/com.good.gd/dynamics_sdk
        chmod -R u+wx platforms/android/com.good.gd

        # Create the directory for compiler output.
        mkdir platforms/android/output

        copyIDEATemplate "../../src/${APP_ID}/template" "platforms/android/"
    
        echo "Overwriting settings.json file."
        cat >platforms/android/assets/settings.json <<SETTINGS.JSON
{
    "GDApplicationID":"$APP_ID",
    "GDApplicationVersion":"1.0.0.0",
    "GDLibraryMode": "GDEnterprise",
    "GDConsoleLogger": [
        "GDFilterErrors",
        "GDFilterWarnings",
        "GDFilterInfo",
        "GDFilterDetailed",
    ]
}
SETTINGS.JSON

        cat <<'MANIFEST.NOTE'

Sorry, this script does not insert the GDApplicationVersion meta-data tag in the
AndroidManifest.xml file. Best practice is to insert a tag like the following in
the <application> item.

        <meta-data
            android:name="GDApplicationVersion"
            android:value ="1.0.0.0" />

MANIFEST.NOTE

        echo "Changing project name in .project file"
        sed -i -e 's/>'"$APP_NAME"'</>'"$APP_NAME"' (PhoneGap)</' platforms/android/.project
        
        # Switch back to initial directory
        cd ..
    fi

    if test -d "${APP_NAME}/platforms/ios" ;
    then
        # Enable GD for iOS
        cd "${GD_PLUGIN_DIR}/iOS/SampleApplications/UpdateApp-Cordova3x/"
        ENABLESH='./FIXEDgdEnableApp.sh'
        if test '!' -f "$ENABLESH" ;
        then
            echo 'No FIXED script for iOS. Assuming fixed version was installed.'
            ENABLESH='./gdEnableApp.sh'
        fi
        bash "$ENABLESH" -c "$APP_ID_PREFIX" -g "$ORGANISATION_NAME" \
            -i "$APP_ID" -p "${PROJECT_DIR}/platforms/ios/"
        
        cd "$PROJECT_DIR"

        echo "Refreshing contributor plugin to fix Info.plist file."
        cordova plugin remove com.good.example.contributor.jhawkins
        cordova plugin add ../../src/com.good.example.contributor.jhawkins

        echo "Fixing deployment target, if necessary."
        sed -i \
            -e 's/IPHONEOS_DEPLOYMENT_TARGET = 5\.0;/IPHONEOS_DEPLOYMENT_TARGET = 6.0;/g' \
            "platforms/ios/${APP_NAME}.xcodeproj/project.pbxproj"
        
        cat <<ARCHITECTURES.NOTE

Sorry, this script does not fix the Architectures and Valid Architectures in
the project for iOS. You might need to do that yourself, in Xcode, before
building for iOS.

ARCHITECTURES.NOTE
        # Switch back to initial directory
        cd ..
    fi
    
    # Remove temporary copy of the plugins.
    rm -rf "$PLUGINS_TMP"
}
# create()
function copyIDEATemplate
{
    local SRC_PATH="$1"
    shift
    local DEST_PATH="$1"
    shift
    
    echo 'Copying IDEA template.'
    ls -la "$DEST_PATH/libs"

    cp -r "$SRC_PATH/android.idea/" $DEST_PATH/.idea
    chmod -R u+wx $DEST_PATH/.idea
    # printf is more portable than echo -n
    printf "$APP_NAME" > "$DEST_PATH/.idea/.name"

    # Overwrite the android.iml file with something that includes all the files
    # that happen to be in the android/libs directory.
    #
    # Preamble ...
    cat >"$DEST_PATH/.idea/android.iml" <<'ANDROID.IML'
<?xml version="1.0" encoding="UTF-8"?>
<module type="JAVA_MODULE" version="4">
  <component name="FacetManager">
    <facet type="android" name="Android">
      <configuration>
        <option name="GEN_FOLDER_RELATIVE_PATH_APT" value="/../../android/gen" />
        <option name="GEN_FOLDER_RELATIVE_PATH_AIDL" value="/../../android/gen" />
        <option name="MANIFEST_FILE_RELATIVE_PATH" value="/../../android/AndroidManifest.xml" />
        <option name="RES_FOLDER_RELATIVE_PATH" value="/../../android/res" />
        <option name="ASSETS_FOLDER_RELATIVE_PATH" value="/../../android/assets" />
        <option name="LIBS_FOLDER_RELATIVE_PATH" value="/../../android/libs" />
        <option name="PROGUARD_LOGS_FOLDER_RELATIVE_PATH" value="/../../android/proguard_logs" />
        <option name="ENABLE_MANIFEST_MERGING" value="true" />
      </configuration>
    </facet>
  </component>
  <component name="NewModuleRootManager" inherit-compiler-output="true">
    <exclude-output />
    <content url="file://$MODULE_DIR$">
      <sourceFolder url="file://$MODULE_DIR$/gen" isTestSource="false" generated="true" />
      <sourceFolder url="file://$MODULE_DIR$/src" isTestSource="false" />
    </content>
    <orderEntry type="jdk" jdkName="Android API 19 Platform" jdkType="Android SDK" />
    <orderEntry type="sourceFolder" forTests="false" />
    <orderEntry type="module" module-name="CordovaLib" exported="" />
    <orderEntry type="module" module-name="gdHandheld" exported="" />
ANDROID.IML
    #
    # ... per file part ...
    local LIB_FILES=`ls "$DEST_PATH/libs"`
    #
    for LIB_FILE in $LIB_FILES
    do
        cat >>"$DEST_PATH/.idea/android.iml" <<ANDROID.IML
    <orderEntry type="module-library" exported="">
      <library>
        <CLASSES>
          <root url="jar://\$MODULE_DIR\$/libs/${LIB_FILE}!/" />
        </CLASSES>
        <JAVADOC />
        <SOURCES />
      </library>
    </orderEntry>
ANDROID.IML
    done
    #
    # ... end of the file.
    cat >>"$DEST_PATH/.idea/android.iml" <<'ANDROID.IML'
  </component>
</module>
ANDROID.IML

    cp "$SRC_PATH/CordovaLib.iml" \
        $DEST_PATH/CordovaLib/CordovaLib.iml
    cp "$SRC_PATH/gdHandheld.iml" \
        $DEST_PATH/com.good.gd/dynamics_sdk/libs/handheld/gd/gdHandheld.iml
    chmod u+w \
        $DEST_PATH/CordovaLib/CordovaLib.iml \
        $DEST_PATH/com.good.gd/dynamics_sdk/libs/handheld/gd/gdHandheld.iml
}
# copyIDEATemplate()

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
        rebuild
    else
        # One or more error messages will have been printed already.
        exit 1
    fi
else
    rebuild
fi
