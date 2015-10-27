Good Dynamics Contributor Code for Android
==========================================
To use the contributor applications and code with Android Studio for the first
time, follow these instructions:

1.  Download and unzip the repository, or use git or some other means to obtain
    the files.
2.  Change to the `forAndroid/` sub-directory of wherever you put the files.
    This directory should have the structure described under the Structure
    heading, below.
3.  Create a new sub-directory `com.good.gd/`.
4.  Copy the whole `dynamics_sdk/` directory from wherever you installed the
    Good Dynamics SDK for Android under the new sub-directory.

    The typical installed location of the required directory is
    `$ANDROID_HOME/extras/good/dynamics_sdk/`.

    The directory structure should now be as follows:
    
        forAndroid/
                  /build.gradle
                  /com.good.gd/                  (Directory you created.)
                              /dynamics_sdk/     (Directory you copied.)
                  /contributorLibrary/
                  /samples/
                          /AppKinetics Workflow/
                          /Enterprise/
                  /readme.md                     (This file.)
                  /settings.gradle
    
5.  Ensure that the `dynamics_sdk/` directory is writeable and traversable,
    for example by running a command like `chmod -R u+wx com.good.gd` in a
    terminal window.
6.  Open Android Studio. Select to Import project from the `settings.gradle`
    file in the top-level directory. If prompted, you can select to use the
    gradle wrapper, and reload the project for language level changes.

The contributor applications for Android are now ready to use. You can run them
on an emulator or real device.

For general details about Good Dynamics contributor code see the readme file in
the parent repository.

Structure
---------
This directory has the following sub-directories: 
`contributorLibrary/` which contains common code.  
`samples/` which contains sample applications that use the common code.

The whole structure has a top-level `settings.gradle` file, which defines a
single project that includes all the common code and the sample applications.

Compatibility
-------------
The contributor code has been tested in the following environment.

Component                       | Version
--------------------------------|--------
Android Studio                  | 1.4
JRE                             | 1.7.0
Android SDK Tools               | 24.4.1
Physical device running Android | 5.0.1
Good Dynamics SDK for Android   | 2.0.1243
Good Control and Good Proxy     | 2.0.3
OS X                            | 10.10.5

The AppKinetics Workflow application has been tested with the following service
provider applications for Android.

Service       | Provider    | Version
--------------|-------------|----------
Send Email    | Good Work   | 1.5.2.158
Open HTTP URL | Good Access | 2.4.0.1216
Transfer File | Good Share  | 3.2.0
