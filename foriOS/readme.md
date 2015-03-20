Good Dynamics Contributor Code for iOS
======================================
To use the contributor applications and code for iOS with Apple Xcode for the
first time, the following steps can be followed.

1.  Download and unzip the repository, or use git or some other means to obtain
    the files.
2.  Open the `.xcodeproj` file for the required sample.
3.  Open the target, and navigate to the Copy Bundle Resources list in the Build
    Phases tab.
4.  Remove the existing `GDAssets.bundle` reference and replace with a reference
    to your own. Link the resources in the usual way; do not copy them.

The contributor applications for iOS are now ready to use. You can run them on a
simulator or real device.

For general details about Good Dynamics contributor code see the readme file in
the parent repository.

Structure
---------
This directory has two sub-directories: 
`src/` which contains common code.  
`samples/` which contains sample applications that use the common code.

Compatibility
-------------
The contributor code has been tested in the following environment.

Component                       | Version
--------------------------------|--------
Xcode                           | 6.1.1
iOS simulator running iOS       | 8.1
iPad device running iOS         | 8.1.3
Good Dynamics SDK for iOS       | 1.10.4366
Good Control and Good Proxy     | 1.9.45
OS X                            | 10.10.2

The AppKinetics Workflow application has been tested with the following service
provider applications.

Service       | Provider    | Version
--------------|-------------|----------
Send Email    | Good Work   | 1.3.0.159
Open HTTP URL | Good Access | 2.2.0.402
Transfer File | Good Share  | 3.1.9
