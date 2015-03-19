Good Dynamics Contributor Code
==============================
This repository contains Good Dynamics&trade; contributor sample code. Good
Dynamics (GD) is the Good Technology&trade; platform for secure mobile
application development. To make use of the sample code in this repository you
will need the following.

- An account on the [Good Developer Network](https://developer.good.com).
- To have installed the GD SDK for Android or the GD SDK for iOS, or both.
- A deployment of GD, i.e. Good Control and Good Proxy servers.

Contents
--------
The contributor code includes a number of complete GD applications.

### AppKinetics Workflow
The AppKinetics Workflow contributor application can be used to demonstrate the
following tasks:

-   Send an email with To, Cc and Bcc addresses; a subject line and body text;
    and a number of file attachments. You must have Good Work&trade; or Good for
    Enterprise&trade; installed to demonstrate this. (Sorry, the contributor
    application for PhoneGap only demonstrates a subset of email features, at
    time of writing.)
-   Send a file to another application that provides the Transfer File service,
    for example Good Share.
-   Receive a file from another application that consumes the Transfer File
    service.
-   Open an HTTP URL. You must have Good Access or another secure browser
    installed to demonstrate this.

The demonstrations use simple diagnostic data that is generated within the
application.

### Enterprise
The Enterprise contributor application illustrates:

-   How to retrieve the generic application configuration from the enterprise
    Good Control (GC) server.
-   How to retrieve custom application policy setttings from the GC.
-   How to receive notifications of changes to application configuration and
    application policy settings.
-   How to utilise the GD Authentication Token mechanism for end user
    authentication.

Sorry, there is no Enterprise contributor application for PhoneGap at time of
writing.

An application server is required to use the GD Authentication (GD Auth) Token
mechanism. This repository includes a sample application server, minipush,
implemented as a Perl script.

Structure
---------
Project files and source code are provided for Android, for iOS and for
PhoneGap. A couple of server-side files are also provided.

There are four sub-directories in the repository: `forAndroid/`, `foriOS/`,
`forPhoneGap/`, and `forServers/`. Each of the sub-directories contains a readme
file that explains how to use the sample code in that sub-directory.
