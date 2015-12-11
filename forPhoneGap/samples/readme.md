Contributor Sample Application for PhoneGap
===========================================
This directory contains a script that creates a contributor sample application
for the Good Dynamics (GD) PhoneGap Plugin.

Source Location
---------------
The source for the sample is in the sub-directories of the `src/` sub-directory
of this repository. Part of the source is copied by the script. The rest is a
Cordova plugin.

This seems to be the easiest and cleanest way to publish the code.

Getting the sample application
------------------------------
To create the contributor sample application:

1.  Download and unzip the Good Dynamics PhoneGap Plugin. Make a note of the
    path of the directory in which you extracted it.
2.  Download and unzip the repository, or use git or some other means to obtain
    the files.
3.  Apply the fixes for known issues to the gdEnable script for Android and to
    the project template for iOS. See the `scripts/` sub-directory of this
    repository for instructions.
4.  Open a terminal window and cd to this `samples/` directory in your copy.

    If you have previously built the samples in this directory, and want to
    update to the latest sample code and GD SDKs, then delete the sample project
    before proceeding. For example, run the following command line:
    
        rm -rf 'AppKinetics Workflow'

5.  Run the `build.sh` script. Specify the directory in which you extracted the
    GD PhoneGap Plugin download as the command line parameter. Like this:

        ./build.sh /path/to/plugindownload
    
    In case you are not sure you have the correct path you can check that your
    `path/to/plugindownload` directory has `iOS/` and `Android/`
    sub-directories.
    
    The script output might advise you of some necessary manual changes to make
    to your projects. Make those changes before proceeding.

6.  This will create a sub-directory that contains a Cordova project for the
    sample application.

It's a good idea to edit the top of the `build.sh` script. See the comments
there for what to populate.

Running the sample application on Android
-----------------------------------------
To run the sample application on an Android device:

1.  Get and create the sample application, by following the instructions under
    Getting the sample application, above. This will create a Cordova project.
2.  Open Android Studio.
3.  On the welcome screen, select the Import project (Eclipse ADT, Gradle, etc.)
    option. This opens a project selection dialog.
4.  Navigate to the `platforms/android/` sub-directory of the application
    project. Select the `settings.gradle` file. This creates a new project and
    opens it in a project window. The project name will be "android".
    
    You might encounter a number of error messages and prompts to fix Gradle
    issues. It is OK to take all the default options and fixes.

5.  Select to run the application from within Android Studio in the usual way.
    There is a run configuration in the project.

It might take a minute or two to build the executable the first time. You might
be prompted to select a device or emulator when the build finishes.

Running the sample application on iOS
-------------------------------------
To run the sample application on an iOS device:

1.  Get and create the sample application, by following the instructions under
    Getting the sample application, above. This will create a Cordova project.
2.  Start Apple Xcode and then open the project in the `platforms/ios/`
    sub-directory of the Cordova project. The item that you open will have a
    `.xcodeproj` suffix.
3.  Select to build or run the application from within Xcode in the usual way.

In case the build fails, check under Known Issues, below, for a fix.

Editing the sample application
------------------------------
The `build.sh` script can also be used to resynchronise the platform `www/`
files from the project `www/` files, in case you want to edit the sample
application.

Run the script from the `samples/` directory, as above, or cd into the project
directory and run it as `../build.sh` with a relative path.

Known Issues
------------

### Source files removed from project for iOS
Sometimes the `CDVFile.m` file seems to get removed from the Compile Sources
list in the platform project for iOS. If this happens, you will see build errors
relating to the Cordova File plugin like:

    Undefined symbols for architecture armv7s:
        "_OBJC_CLASS_$_CDVFilesystemURL", referenced from:
            objc-class-ref in CDVLocalFilesystem.o
        "_OBJC_CLASS_$_CDVFile", referenced from:
            objc-class-ref in CDVCapture.o
            objc-class-ref in CDVFileTransfer.o
            (maybe you meant: _OBJC_CLASS_$_CDVFileTransferEntityLengthRequest,
                _OBJC_CLASS_ $_CDVFileTransfer ,
                _OBJC_CLASS_$_CDVFileTransferDelegate )
    ld: symbol(s) not found for architecture armv7s

To fix this issue, add the `CDVFile.m` file back to the Compile Sources in the
application target.

Sometimes other `.m` files get removed from the Compile Sources list in the
platform project for iOS. You can spot them quite easily by opening the add
sources dialog and looking for any `.m` files, which have a different icon to
the `.h` files.

### No application icon for Easy Activation
If you delegate activation to another application, no sample application icon is
not shown on the Easy Activation unlock screen in the other application. The fix
is to remove from the sample application's Info.plist file all the property
settings that relate to the application icon, for example the
`CFBundleIconFile`, `CFBundleIcons`, and `CFBundleIcons~ipad` settings.

Compatibility
-------------
The script and sample application have been tested in the following environment:  

Component                       | Version
--------------------------------|------------
Android Studio                  | 1.5.1
JRE                             | 1.7.0
Android SDK Tools               | 24.4.1
Physical device running Android | 5.0.1
Good Dynamics SDK for Android   | 2.0.1243
Apple Xcode                     | 6.4
iPad device running iOS         | 9.1
Good Dynamics SDK for iOS       | 2.0.43
Cordova                         | 4.3.1
Good Dynamics PhoneGap Plugin   | 2.0.71
Good Control                    | 2.0.3.14 
OS X                            | 10.10.5

The AppKinetics Workflow application has been tested with the following service
provider applications.

Service       | Provider    | Version for Android | Version for iOS
--------------|-------------|---------------------|----------------
Send Email    | Good Work   | 2.0.0.201           | 2.0.0.391
Open HTTP URL | Good Access | 2.4.4.664           | 2.4.4.740
