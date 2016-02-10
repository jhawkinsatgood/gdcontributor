Authserv Protocol
=================
The authserv protocol is a simple protocol for demonstration of the Good
Dynamics Authentication Token mechanism. Commands in the protocol are sent by
the client, a mobile Good Dynamics (GD) application, and received by the server,
which sends responses.

The protocol has the following commands. The command text is followed by a line
break. If the command has a parameter then this is sent on the next line, also
followed by a line break.

Request Challenge
-----------------
The command `CHALLENGE` requests a challenge string from the server. The server
generates a challenge string, and responds by sending back the string and a line
break.

Verify Token
------------
The command `TOKEN` sends a GD Auth token for verification. The token value is
sent on the following line. The server validates the token by connecting to the
enterprise Good Proxy (GP) service and responds by sending two lines, as
follows:

1.  The first line contains:
    -   `OK` if the token was OK.
    -   `FAIL` if the token failed validation.
2.  The second line contains some text from the GP to which the server connected
    in order to validate the token.
