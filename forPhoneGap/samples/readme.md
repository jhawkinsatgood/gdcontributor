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
5.  Run the `build.sh` script. Specify the directory in which you extracted the
    GD PhoneGap Plugin download as the command line parameter. Like this:

        ./build.sh /path/to/plugindownload
    
    Note that the `path/to/plugindownload` directory will have `iOS/` and
    `Android/` sub-directories.

6.  This will create a sub-directory that contains a Cordova project for the
    sample application.

It's a good idea to edit the top of the `build.sh` script. See the comments
there for what to populate.

Running the sample application on Android
-----------------------------------------
To run the sample application on an Android device:

1.  Get and create the sample application, by following the instructions under
    Getting the sample application, above. This will create a Cordova project.
2.  Start Android Studio and select to Open an existing project. Select the
    `platforms/android/` sub-directory of the Cordova project. Don't select to
    migrate the project to Gradle, if prompted.
3.  Select to run the application from within Android Studio in the usual way.
    There is a run configuration, `Application`, in the project.

It might take a minute or two to build the executable the first time. You will
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
Android Studio                  | 1.1.0
JRE                             | 1.7.0
Android SDK Tools               | 24.0.2
Physical device running Android | 4.4.2
Good Dynamics SDK for Android   | 1.10.1178
Apple Xcode                     | 6.2
iPad device running iOS         | 8.1.3
Good Dynamics SDK for iOS       | 1.10.4368
Cordova                         | 3.5.0-0.2.7
Good Dynamics PhoneGap Plugin   | 1.10.40
Good Control and Good Proxy     | 1.9.45
OS X                            | 10.10.2

The AppKinetics Workflow application has been tested with the following service
provider applications.

Service       | Provider    | Version for Android | Version for iOS
--------------|-------------|---------------------|----------------
Send Email    | Good Work   | 1.3.0.57            | 1.3.0.159
Open HTTP URL | Good Access | 2.2.0.303           | 2.2.1.405
