Contributor Fixes
=================
This directory contains contributed fixes to the scripts and templates in the GD
PhoneGap Plugin.

The fixes are for version 1.10.40 of the plugin.

Installation
------------
The fixes can be installed after the plugin has been installed. Here is the
recommended procedure. __You will need to know the GD PhoneGap Plugin
installation directory, i.e. the location where the plugin download was
uncompressed.__

1.  Copy the fixed script for Android into the same directory as the originals.

    The fixed scripts have the same names as the originals with a FIXED prefix.
    -   Copy `Android/FIXEDgdEnableApp.sh` from here to the
        `Android/GDCordova3x/` sub-directory of the plugin installation
        directory.

2.  Ensure that the copy of the FIXED script is executable by you.

3.  Make a safe copy of the project template for iOS.

    The easiest way to do the following may be in a terminal window.
    
    1.  Open the directory that contains the project template. This will be the
        following sub-directory of the plugin install directory:

            iOS/SampleApplications/UpdateApp-Cordova3x/__TemplateAppName__/__TemplateAppName__.xcodeproj/

    2.  Copy the `project.pbxproj` file to a safe name, such as
        `ORIGINALproject.pbxproj`.
    
4.  Ensure that the original `project.pbxproj` file is writable by you.

5.  Replace the original project template with the fixed project template.

    -   Copy `iOS/project.pbxproj` from here over the original `project.pbxproj`.

There is no need to fix the project templates for Android.

Usage
-----
Run the FIXED script instead of the original for Android.  
Run the original script for iOS. It will pick up the overwritten version of the
template.
