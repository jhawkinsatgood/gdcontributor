How to use the source code in this directory
============================================
The source code in this directory tree can be used to demonstrate Good Dynamics
(GD) application-based services.

Set up the projects
-------------------

1.  Create two GD Cordova projects: gdservicesdemoa and gdservicesdemob. Follow
    the instructions in the technical workbook:  
    Add security with the Good Dynamics PhoneGap Plugin

2.  Copy the code from the sub-directory A/ into the gdservicesdemoa project.
3.  Copy the code from the sub-directory B/ into the gdservicesdemob project.
4.  Copy the code from the sub-directory common/ into both projects.
5.  Rebuild both projects.

Set up the applications
-----------------------

1.  Set up the applications in your Good Control server. Set up GD Application
    Identifiers and native application identifiers.
2.  Register the gdservicesdemoa application as a provider of the service
    `com.good.gdservice.launchable` by using the "Bind Service" option.
3.  Install both applications on the same device, activated by the same end
    user. Install using the integrated development environment, for example
    Xcode.
4.  Obtain an application that is a provider of the Transfer File service. For
    example, the AppKinetics Workflow contributor application.
5.  Install the third application on the same device, activated by the same end
    user.
6.  Uninstall any other GD applications from the device.

Demonstrations
==============
Start both gdservicesdemoa and gdservicesdemob on a device or simulator, in such
a way that the Cordova console output can be seen. For example, start it from
Xcode.
    
Demonstration one: Send a file from one application to another
------------------------------------------------------------
Demonstrate sending a file from one application to another by:

1.  Open the gdservicesdemoa application.
2.  Tap the Consume button.

The provider application, for example AppKinetics Workflow, should be opened and
receive a short text file from gdservicesdemoa.

Logs like the following should be written to the console:

    2015-12-07 19:15:36.543 Services Demonstration A[1585:212709] Provider
    details: {"applicationId":"com.good.example.contributor.jhawkins.appkinetic
    sworkflow","versionId":"1.0.0.0","name":"Sample - AppKinetics
    Workflow","address":"com.good.example.contributor.jhawkins.appkineticsworkflow"}

    2015-12-07 19:15:36.543 Services Demonstration A[1585:212709] About to
    callAppKineticsService(com.good.example.contributor.jhawkins.appkineticsworkflow,
    com.good.gdservice.transfer-file,1.0.0.0,transferFile, null, ["/att0.txt"],,)
    
Then more lines of logging until:

    2015-12-07 19:15:36.572 Services Demonstration A[1585:212709] Request sent:
    Send Complete

Demonstration two: Send structured data from one application to another
-----------------------------------------------------------------------
Demonstrate sending sending structured data from one application to another by:

1.  Open the gdservicesdemoa application.
2.  Tap the Provide button. Periodic logs will now be written to the console.
3.  Open the gdservicesdemob application.
4.  Tap the Consume button in the B application.

The gdservicesdemoa application should be opened and receive some structured
data from gdservicesdemob.

Logs like the following should be written to the console of the gdservicesdemoa
application. When the Provide button is tapped:

    2015-12-08 11:12:50.714 Services Demonstration A[1732:252348] GDAppKinetics
    - readyToProvideService: called - service com.good.gdservice.launchable,
      version 1.0.0.0, # of waiting services 0
    2015-12-08 11:12:51.715 Services Demonstration A[1732:252348] GDAppKinetics
    - readyToProvideService: called - service com.good.gdservice.launchable,
    version 1.0.0.0, # of waiting services 0

When the Consume button is tapped in the gdservicesdemob application, a line
like the following should be written to the console of the gdservicesdemoa
application.

    ProvideService: called - service com.good.gdservice.launchable, version
    1.0.0.0, # of waiting services 0

Then some more lines of logging until:

    2015-12-08 11:16:08.733 Services Demonstration A[1732:252348]
    receivedRequest:{"applicationName":"com.goodinternal.jhawkins.gdservicesdemob",
    "attachments":[],"method":"launch","serviceName":"com.good.gdservice.launchable",
    "parameters":{"textValue":"Text Value","arrayOfStrings": ["First String",
    "Second String","Third String"],"numericValue":23},"version":"1.0.0.0"}
    2015-12-08 11:16:08.734 Services Demonstration A[1732:252348] No attachments.

At the same time, lines like the following should be written to the console of
the gdservicesdemob application:

    2015-12-08 11:16:05.108 Services Demonstration B[1746:254481] Provider details:
    {"applicationId":"com.goodinternal.jhawkins.gdservicesdemoa",
    "versionId":"1.0.0.0","name":"GD Services Demonstration A",
    "address":"com.goodinternal.jhawkins.gdservicesdemoa"}
    2015-12-08 11:16:05.108 Services Demonstration B[1746:254481] About to
    callAppKineticsService(com.goodinternal.jhawkins.gdservicesdemoa,
    com.good.gdservice.launchable,1.0.0.0,launch, {"textValue":"Text Value",
    "numericValue":23,"arrayOfStrings":["First String","Second String","Third
    String"]}, [],,)

Then some more lines of logging until:

    2015-12-08 11:16:05.334 Services Demonstration B[1746:254481]
    Request sent:Send Complete

