Good Dynamics Contributor Code for Servers
==========================================
This directory contains contributor code for use on the server side of a Good
Dynamics (GD) deployment.

For general details about Good Dynamics contributor code see the readme file in
the parent repository.

Sample Application Policy Definition
====================================
The `com.good.example.contributor.jhawkins.enterprise.applicationpolicy.xml`
file contains a sample application policy definition. This file can be used with
the Enterprise contributor application for Android and for iOS.

To use this file, upload it using the Good Control console application
management screens.

For details on the custom Application Policy feature, see the
[technical brief](https://community.good.com/docs/DOC-1543) on the Good
Developer Network (GDN) website.

Application Server
==================
The `minipush.pl` file contains an application server. The server can be used
with the Enterprise contributor application for Android and for iOS.

Installing the server
---------------------
Copy the file to the machine on which it will run. The machine will require the
following.
-   An installation of Perl. This probably comes as standard on Mac or debian.
    On Windows, a free distribution such as Strawberry perl could be used. Mac
    ports can also provide a perl distribution.
-   A number of Perl modules from CPAN. The complete list of Perl modules
    required by the script is as follows.

        Modern::Perl
        String::Random
        IO::Socket
        IO::Socket::SSL
        Net::Address::IP::Local
        Getopt::Std

    You can obtain modules from CPAN by running commands like the following:

        cpan install Modern::Perl

    Or the following:

        sudo cpan install Modern::Perl

    Depending on operating system.

-   An IP address that can be routed to by your GD deployment, specifically the
    Good Proxy (GP) server. One way to set this up is:
    1.  Run the script on its host as follows:
    
            perl ./minipush.pl http404

        This should product output like the following:

            Opening listen socket: ...
            Listen socket open
            192.168.1.155:54011

        Followed by some other output. The numbers will be different for your
        machine. Note the IP address and port number, which are `192.168.1.155`
        and `54011` respectively in the above.
    2.  Key Ctrl-C to terminate the server.
    3.  Add the IP address to the hosts file of the machine that hosts the GP
        server. The hosts file for Windows Server 2008 is at the following path:
        
            C:\Windows\System32\drivers\etc\hosts
        
        You might have to make it writable to users in order to edit it.
        
        The format required is: `<IP address> <machine name>`
        
        The IP address in the above could be added as:

            192.168.1.155 minipush.jhawkins.a.com
        
        Note that a fully qualified domain name (FQDN) has been used. This is
        necessary, although there is no need for the domain to be valid.
    
    You can test the IP address configuration by running the operating system
    ping utility on the GP machine.
    
    Restart the GP service after changing the hosts file.

-   A route to a GP server in your deployment. You can determine the IP address
    of the GP server from the built-in operating system tools and console. For
    example, the Windows Control Panel shows the IP address as follows.
    
    1.  Open the Network and Sharing Center: Start, Control Panel, View network
        status and tasks.
    2.  Click one of the Local Area Connection items on the right-hand-side of
        the window, just above the divider for Change your networking settings.
        This opens the Local Area Connection Status dialog for the selected
        adaptor. (Select an adaptor that corresponds to a real network adaptor
        that is actually connected.)
    3.  Click Details to open the Network Connection Details dialog, which lists
        a number of properties and values. This includes IPv4 Address.
    4.  Check that you can ping the GP server machine, at the IP address, from
        the machine on which you will be running the minipush server. If you
        cannot, try the IP address of another Local Area Connection item. (Note:
        Even a connection that cannot connect to the Internet might still be
        useable for connection from the application server.)
        
    Then check that the minipush server can reach the GP, by running a command
    like:
    
        perl ./minipush.pl -a <server address> -p 17080 one
    
    This should produce output like:
        
        $ perl minipush.pl -a 192.168.56.101 -p 17080 one
        Sending Push Channel message:
          Service address: "192.168.56.101"
          Service port: 17080
          Token: ""
          Message: ""
        
        Opening plain socket to Push Channel service: 192.168.56.101 17080 ...
        Socket to Push Channel service open
        consumeGNP
          1 HTTP/1.1 200 OK
          2 Content-Type: text/plain
          3 X-Good-GNP-Code: 402 Invalid Token
          4 Content-Length: 0
          5 
        checkToken response from Push Channel service:
        HTTP/1.1 200 OK
        Content-Type: text/plain
        X-Good-GNP-Code: 402 Invalid Token
        Content-Length: 0
        
        Closing socket.
        Token invalid, notification skipped.

Configuring your GD deployment
------------------------------
After the server is installed, you can configure connection to it from the GD
deployment. Here is one way:

1.  Open the Good Control (GC) console and log in as an administrator.
2.  Open the Manage Applications screens, and locate the mobile application
    that will connect to the server. This could be the Enterprise contributor
    application, for example.
3.  Click the pencil icon to edit the individual application. This opens the
    Manage Application screen for the application.
4.  Open the Servers tab.
5.  Enter the FQDN and port number that you noted earlier and click Submit to
    save the configuration.
    
This enables connection to the application server from the GD deployment, and
hence from GD mobile applications activated for its end users.

Running the server for GD Authentication Token validation
---------------------------------------------------------
After configuring your GD deployment, and when you are ready to connect to the
application server from a GD mobile application, run the server as follows.

1.  Start the server running on the same port as before, and connecting to the
    GP, with a command line like:
    
        perl ./minipush.pl -a <GP IP address> -p 17080 authserv <port number>
    
    This should produce output that starts like:
    
        $ perl ./minipush.pl -a 192.168.56.101 -p 17080 authserv 54187

        Opening listen socket: 54187...
        Listen socket open
        10.103.150.18:54187

    The server is now listening on the specified port for authentication token
    validation commands from the Enterprise contributor application. The code
    for this application is in the other directories of this repository.
    
2.  Run the application on a device or in an emulator. Select the Authentication
    Token option in the mobile application. The server should product output
    like the following when the application connects to it. (Long sequences of
    characters have been replaced by ... to aid readability.)
    
        Client connection
        Sleeping for 1s ...
        Awake
        authserv
          1 CHALLENGE
        Command: "CHALLENGE"
        Generated challenge string: "..."
        Sending...
        Done.
          2 TOKEN
        Command: "TOKEN"
          3 ...
          4 
        Token received "..."
        Validating...

        Opening plain socket to Push Channel service: 192.168.56.101 17080 ...
        Socket to Push Channel service open
        recvAuthToken
          1 HTTP/1.1 200 OK
          2 Content-Type: text/plain
          3 X-Good-GD-AppID: com.goodinternal.example.contributor.jhawkins.enterprise
          4 X-Good-GD-ContainerID: ...
          5 X-Good-GD-AuthChallenge: ...
          6 X-Good-GD-Server: minipush.jhawkins.a.com
          7 X-Good-GD-AuthTokenVersion: 2
          8 X-Good-GD-AuthResponseCode: 100 OK
          9 X-Good-GD-UserID: gcadmin@jhawkins.a.com
         10 X-Good-GD-AuthTokenCreationTime: 1410183964
         11 Content-Length: 0
         12 
        Finished
        Closed

The server is then running and validating GD Auth tokens by calling an HTTP
service on the GP.

Other execution modes
---------------------
The minipush server has a number of other execution modes. Run the script with a
`-u` or `-U` command line switch for more information.

