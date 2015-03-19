#!/usr/bin/perl -w
#
# Copyright (c) 2014 Good Technology Corporation
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
#
# minipush: Minimal Good Dynamics Push Channel application server
# ===============================================================
# This is a minimal server intended to demonstrate the following capabilities:
# -   Validate Good Dynamics Authentication Tokens.
# -   Check the validity of a PushChannel token.
#     The token can be:
#
#     -   Received on a direct socket connection from a Good Dynamics application.
#     -   Entered as a command line parameter.
#
#     Either way, this is out-of-band to the Good Dynamics protocols.
#
# -   Send a Push Channel notification using a validated token.
# -   Send data to the client using the socket connection.
#
# The server is written as a perl script, because perl is commonly available.
#
# To use this perl script the following are required:
#
# -   Installation of perl. This probably comes as standard on Mac or debian. On 
#     Windows, a free distribution such as Strawberry perl could be used.
#     Mac ports can also provide a perl distribution.
# -   The required perl modules, which can be obtained from CPAN, by running
#     commands like the following:
#
#         cpan install Modern::Perl
#         cpan install Net::Address::IP::Local
#
#     or:
#
#         sudo cpan install Modern::Perl
#         sudo cpan install Modern::Perl
#
#     depending on operating system.
#
# Quick Start
# -----------
# To send a Push Channel message to a running mobile application, that has
# already obtained a token:
# 1.  cd to whatever directory contains the script, and run:
#
#         perl ./minipush.pl one "token" "message"
#
# For full usage see the help subroutine, look for "sub help" in the script
#

use Modern::Perl;

# Module for long random string generation.
# See http://search.cpan.org/~steve/String-Random-0.22/lib/String/Random.pm
# WARNING: This random string generation module has not been assessed for
# security by Good Technology and is not necessarily suitable for production.
use String::Random qw(random_string);

use IO::Socket;

# Module for SSL/TLS socket connection.
use IO::Socket::SSL;

use Net::Address::IP::Local;

# Module for reading command line switches.
use Getopt::Std;
my %opts;

my $ln = "\r\n";

my $command_line_usage = <<COMMAND_LINE;
Usage:
perl minipush.pl [-a <PCS address>] [-p <PCS port>] [-l] [-n] [-s (0|1|2)]
                 [-S <SSL version string>] [-c <cipher list string>] [-d]
                 (one <token> <message> | auth <token> | push [<port>])
perl minipush.pl (sockum|http404|authserv) [<port>]
perl minipush.pl [-u|-U]
COMMAND_LINE

sub help
{
  print <<HELP;
$command_line_usage
Where:
  -a specifies the address of the Good Dynamics services access point.
  If omitted, gdmdc.good.com is the default, which is the Good Dynamics Network
  Operation Center (NOC). If using a Good Proxy as the access point, specify
  the IP address or server address here.

  -p specifies the port number of the Good Dynamics services access point.
  If omitted, 443 is the default.
  When using a Good Proxy, specify 17080 to use HTTP or 17433 to use HTTPS.
  
  -l overrides the local IP address to 127.0.0.1 and skips attempting to
  discover the machine's IP address. This seems to be necessary sometimes, when
  not conneected to any LAN or WLAN.
  
  -n specifies only call notify, not checkToken.
  
  -s specifies whether to use SSL or a plain socket:
  -s 0 specifies not to use SSL.
  -s 1 specifies to use SSL.
  -s 2 specifies to use SSL if the port number ends in 443 or 433.
  If omitted, -s 2 is the default.
  
  -S specifies an SSL version string.
  -c specifies an SSL cipher list string.
  -d is a shorthand for -S 'SSLv23:!SSLv2:!TLSv12' -c ''
  These have been found to be useful SSL options to specify.

  The next command line parameter specifies the execution mode.
  "one" mode sends one Push Channel message. This causes a checkToken and then
  a notify command to be sent to the Good Dynamics services access point.
  <token> is the Push Channel token, which must have been obtained by a mobile
          GD application using the GD Runtime API for the mobile platform:
            GDPushChannel when using GD for iOS.
            PushChannel when using GD for Android.
  <message> is the message to send in the notification payload.

  "auth" mode checks a GD Auth token. This causes a verifyGDAuthToken command
  to be sent to the GD Auth service.
  <token> is the GD Auth token, which must have been obtained by a mobile
          GD application using the GD Runtime API GDUtility.

  "push" mode will expect push notification parameters to be sent by the
  client, and will then take action, including sending a Push Channel message.
  This is a listening mode.

  "sockum" mode accepts a SOCKUM command and then sends data to the client.
  No Push Channel message is sent in this mode. This is a listening mode.

  "http404" mode dumps whatever the client sends, and then sends a minimal HTTP
  404 response. This is a listening mode.
  
  "authserv" mode will expect GD authentication token parameters to be sent by
  the client, and will then take actions such as verifying tokens. This is a
  listening mode.
  If a Good Dynamics services access point has not been specified, this mode
  uses the inbound IP address by default.

  In listening modes:
  <port> is the optional port on the local machine to which minipush will
         listen. If omitted, minipush will acquire the next available port.
  
  -u prints short usage and quits.
  -U prints long usage and quits.

Example invocations:

    perl minipush.pl one
Sends an empty message, using a null token, to the NOC Push Channel service.
This can be used to check that connection to the NOC is available. The expected
checkToken response would include the following headers:
    HTTP/1.1 200 OK
    X-Good-GNP-Code: 402 Invalid Token
    Content-Length: 0
    Content-Type: text/plain
Note that the return code is 402, an error, because a nulll token is invalid.

    perl minipush.pl -a goodproxy.corp.example.com -p 17080 one
Sends an empty message, using a null token, to the Push Channel service running
on an enterprise Good Proxy (GP) server, over plain HTTP. This can be used to
check the connection details and availability. The expected response headers
are the same as in the previous invocation.
Change goodproxy.corp.example.com to the address of an enterprise GP server.

    perl ./minipush.pl one "token" "message"
Sends a Push Channel message to a running mobile application, that has already
obtained a token. The token would have to be logged or made available in some
other way, and then entered on the command line, usually in quotes.
HELP
}

sub usage
{
  print <<USAGE;
$command_line_usage
Hint:
  -U prints longer usage information and help
  -d is a shorthand for -S 'SSLv23:!SSLv2:!TLSv12' -c ''
USAGE
}

{
    package MINIPUSH;

    # recvDump - Reads from a socket and dumps to STDOUT. Reads until a blank
    # line is received.
    # Populates an associative array of HTTP-style headers as it goes.
    sub recvDump
    {
      my $socket = shift;
      my $label = shift || 'recvDump';
    
      my %ret = (response=>'',
                 gnpStatus=>0, gnpStatusText=>'',
                 authResponse=>0, authResponseText=>'');
      
      print $label, "\n";
      my $dumpLines = 0;
      
      for(;;) {
        my $sockLine = <$socket>;
        if (!$sockLine) {last;}
        $dumpLines += 1;
        print sprintf("%3d", $dumpLines), ' ', $sockLine;
        if ( $sockLine =~ /^\s*$/ ) { last; }
        $ret{response} .= $sockLine;
        chomp $sockLine;
    
        # Look for a header and value
        if ( $sockLine =~ /^([-\w]+):\s*/) {
          my $hdr = $1;
          if ( $' =~ /\s*$/ ) {
            # print "\"$hdr\" : \"$`\"\n";
            $ret{$hdr} = $`;
            
            # Special treatment of GNP status and text
            if ($hdr eq 'X-Good-GNP-Code') {
              if ( $` =~ /([0-9]+)\s+/ ) {
                $ret{gnpStatus} = 0 + $1;
                $ret{gnpStatusText} = $';
              }
            }
            
            # Special treatment of GD Auth status and text
            if ($hdr eq 'X-Good-GD-AuthResponseCode') {
              if ( $` =~ /([0-9]+)\s+/ ) {
                $ret{authResponse} = 0 + $1;
                $ret{authResponseText} = $';
              }
            }

          }
        }
      }
      
      #for(keys %ret) {
      #  next if ($_ eq 'response');
      #  print 'ret{', $_, '} : "', $ret{$_}, "\"\n";
      #}

      return %ret;
    }
}

{
    package HTTP;

    sub http100continueSock
    {
        my $sock = shift;
        print $sock join $ln,
        "HTTP/1.1 100 Continue",
        "Content-Type: text/html",
        "Content-Length: 0",
        "",
        ""
        ;
    }
    
    # recvHTTP - Reads HTTP from a socket and dumps to STDOUT.
    sub recvHTTP
    {
        my $sock = shift;
        
        my %ret = MINIPUSH::recvDump($sock, 'recvHTTP');
        #my %ret = ( response => "" );
        #
        #print "recvHTTP\n";
        #my $dumpLines = 0;
        #
        #for(;;) {
        #    my $sockLine = <$sock>;
        #    if (!$sockLine) {last;}
        #    $dumpLines += 1;
        #    print sprintf("%3d", $dumpLines) . " " . $sockLine;
        #    
        #    # Leave this loop if there is a blank line
        #    if ( $sockLine =~ /^\s*$/ ) { last; }
        #    
        #    # Look for a header and value
        #    if ( $sockLine =~ /^([^:]*):\s*/) {
        #        my $hdr = $1;
        #        if ( $' =~ /\s*$/ ) {
        #            # print "\"$hdr\" : \"$`\"\n";
        #            $ret{$hdr} = $`;
        #        }
        #    }
        #    $ret{response} .= $sockLine;
        #}

        # If there is a content length, go by that
        if ( (exists $ret{'Content-Length'}) && $ret{'Content-Length'} > 0 ) {
            my $togo = $ret{'Content-Length'};
            my $stopper = "All content read";
            print "Content: $togo ...\n";
            while( $togo > 0 ) {
                my $chr = getc($sock);
                if ( !$chr ) {
                    $stopper = $!;
                    last;
                }
                $togo --;
                $ret{response} .= $chr;
                print $chr;
            }
            print "\n$stopper at $togo.\n";
        }
        # Otherwise, if chunked transfer encoding has been specified, give the
        # client the go-ahead and then read the chunks.
        elsif (
        (exists $ret{'Transfer-Encoding'}) &&
        $ret{'Transfer-Encoding'} eq 'Chunked'
        ) {
            print "Sending continue\n";
            http100continueSock $sock;
            for(;;) {
                my $sockLine = <$sock>;
                if ( $sockLine !~ /^[[:xdigit:]]+/ ) { last; }
                my $togo = hex($&);
                print "Chunk: $togo ...\n";
                while( $togo > 0 ) {
                    my $chr = getc($sock);
                    if ( !$chr ) {last;}
                    $togo --;
                    $ret{response} .= $chr;
                    print $chr;
                }
                print "\nEnd of chunk. ";
            }
            print "\nEnd of content.\n";
        }
        
        return %ret;
    }
    
    sub http404Sock
    {
        my $sock = shift;
        my $content = <<CONTENT;
<html>
<header>
<title>404 Not Found</title>
</header>
<body
><p>This is the minipush server.</p
></body></html>
CONTENT
        my $contentLength = length $content;
        
        print $sock join $ln,
        "HTTP/1.1 404 Not Found",
        "Content-Type: text/html",
        "Content-Length: $contentLength",
        "",
        $content
        ;
    }
}

{
  package GDAUTH;
  
  my @sessions;
  
  sub init
  {
    @sessions = ();
  }
  
  sub authserv
  {
    my $sock = shift;

    print "authserv\n";
    #my %ret = ( response => "" );
    my $dumpLines = 0;
    my $cmd = 0;
    my $token = '';

    for(;;) {
      my $sockLine = <$sock>;
      if (!$sockLine) {last;}
      $dumpLines += 1;
      print sprintf("%3d", $dumpLines) . " " . $sockLine;
      #$ret{response} .= $sockLine;
      chomp $sockLine;
      
      if (!$cmd) {
        $cmd = $sockLine;
        print 'Command: "', $cmd, "\"\n";
        if ($cmd eq 'CHALLENGE') {
          my $challenge = String::Random::random_string('s' x 128);
          print 'Generated challenge string: "', $challenge, "\"\nSending...\n";

          # Store the challenge.
          push @sessions, (challenge=>$challenge);
          
          # Send the challenge back to the client, so that it can generate a
          # token.
          print $sock $challenge, "\n";

          print "Done.\n";
          $cmd = 0;
        }
        elsif ($cmd eq 'TOKEN') {
          # Need to wait for the next lines, which will have the token.
          # Do nothing here so that the loop goes round again.
          $token = '';
        }
        else {
          print 'Unknown command: "', $cmd, "\"\n";
          $cmd = 0;
        }
      }
      elsif ($sockLine =~ /^$/) {
        if ($cmd eq 'TOKEN') {
          print 'Token received "', $token, "\"\nValidating...\n";
          GDAP::useInboundAddrIfUnset $sock;
          my %cmdret = GDAP::authToken $token;
          my $response = 'OK';
          if ($cmdret{authResponse} != 100) {
            $response = 'FAIL';
          }
          print $sock $response, "\n",
            $cmdret{authResponse}, ' ', $cmdret{authResponseText}, "\n";
        }
        # Blank line indicates end of session. Terminate the loop, and hence
        # the subroutine here. The calling subroutine will take care of
        # closing the socket.
        print "Finished\n";
        last;
      }
      else {
        # Processing a command.
        if ($cmd eq 'TOKEN') {
          $token .= $sockLine;
        }
        else {
          print 'Received unexpected input for command "', $cmd, "\".\n";
        }
        
      }
      
    }

    # GDAUTHSERV commands:
    # TOKEN <token>
    # : Validate the token.
    # : Respond with one of the following:
    # :     TOKEN OK if the token is OK and didn't have a challenge.
    # :     TOKEN NG if the token is not valid.
    # :     CHALLENGE OK if the token is OK and the challenge was recognised.
    # : Close the socket.
    # CHALLENGE
    # : Generate and store a challenge string.
    # : Respond with the challenge string.
    # : Close the socket.
    
  }
}

# recvSockum - Reads a Sockum command from a socket and dumps to STDOUT.
# Quits after reading a single command, usually just one line
sub recvSockum
{
    my $sock = shift;

    print "recvSockum\n";
    my %ret = ( response => "" );
    my $dumpLines = 0;

    for(;;) {
        my $sockLine = <$sock>;
        if (!$sockLine) {last;}
        $dumpLines += 1;
        print sprintf("%3d", $dumpLines) . " " . $sockLine;
        $ret{response} .= $sockLine;
        my @fld = split /\s+/, $sockLine;
        # There are five expected fields:
        # $fld[0]: Command, currently always "SOCKUM"
        # $fld[1]: Number of Sockum replies to send
        # $fld[2]: Number of numbers to send in each reply
        # $fld[3]: Number of seconds to wait in between replies
        # $fld[1]: The sequence to be sent at the end of the last reply
        if ($fld[0] eq "SOCKUM") {
            $ret{command} = shift @fld;
            $ret{replies} = 0 + shift @fld;
            $ret{replySize} = 0 + shift @fld;
            $ret{interval} = 0 + shift @fld;
            $ret{terminal} = shift @fld;
            last;
            # In this version, Sockum protocol is only one line, but that might
            # change in future, so the loop is left in place
        }
    }

    return %ret;
}

# recvMinipush - Read minipush protocol commands from a socket.
# There is no definition of minipush protocol beyond what is in this subroutine.
sub recvMinipush
{
    my $acceptSock = shift;
    my %ret = (
        PCSip => "", PCSport => "", pushToken => "",
        notificationCount => 0, notificationDelay => 0
    );
    # A minipush client is expected to send a message, consisting of:
    #
    # Line 1: Push Channel service IP address and port number, or blank
    # This will be either the Good Dynamics Network Operation Center (NOC) or
    # an enterprise Good Proxy server.
    # Port number should typically be:
    #     443 for the NOC over HTTPS.
    #   17080 for an enterprise GP over plain HTTP.
    #   17433 for an enterprise GP over HTTPS.
    # The client can also leave this line blank, in which case the server will
    # use whatever Push Channel service was specified on its command line, or
    # the defaults.
    # 
    # Line 2: Push Channel token
    # This will be used to address Push Channel notifications to the client.
    #
    # Line 3: count delay where:
    # count is the number of notifications to send or 0, see below.
    # delay is the delay in seconds before each notification.
    # count 0 means send one notification with no delay.

    if ($_ = <$acceptSock>) {
        my ($client_ip, $client_port) = split;
        if ($client_ip) { $ret{PCSip} = $client_ip; }
        if ($client_port) { $ret{PCSport} = $client_port; }
        print "Client line 1 read. Values: \"$ret{PCSip}\" \"$ret{PCSport}\"\n";
        # Blank values will be replaced by the calling function
    }
    else {
        print "Could not read from accept socket. $!\n";
        return %ret;
    }

    $ret{pushToken} = <$acceptSock>;
    chomp $ret{pushToken};
    print "Client token: \"$ret{pushToken}\"\n";

    $_ = <$acceptSock>;
    my ($count, $delay) = split;
    if ($count) { $ret{notificationCount} = 0 + $count; }
    if ($delay) { $ret{notificationDelay} = 0 + $delay; }
    print "Client line 3 read. Values: "
        . "\"$ret{notificationCount}\" \"$ret{notificationDelay}\"\n";

    return %ret;
}

# sendSockum - Send Sockum response down a socket connection.
# A Sockum response consists of the following:
# 1. A sequence of Sockum replies, each consisting of:
# 1.1 A copy of the Sockum command, always SOCKUM
# 1.2 The ordinal number of this reply, starting at 1
# 1.3 A space-separated incremental sequence of numbers, starting at 1
# 1.4 The command and ordinal number again
# 2. A Sockum terminator, on a new line.
#
# The number of replies, number of numbers in each reply, and terminator string
# are parameters specified in the original Sockum request.
# The server sleeps for a number of seconds in between each reply. The length of
# the sleep interval is also specified in the original Sockum request.
sub sendSockum
{
    my $sock = shift;
    my %params = @_;
    print "sendSockum(" .
        "$params{replies},$params{replySize},$params{interval})...\n";
    for ( my $i = 1; $i <= $params{replies}; $i++ ) {
        print $sock "$params{command} $i ";
        for ( my $j=1; $j <= $params{replySize}; $j++ ) {
            print $sock "$j ";
        }
        print $sock "$params{command} $i\n";
        print "Done $i. Sleeping for $params{interval}s...\n";
        if ($params{interval} > 0) { sleep $params{interval}; }
    }
    print $sock "$params{terminal}\n";
    print "sendSockum finished. Sleeping again.\n";
    if ($params{interval} > 0) { sleep $params{interval}; }
}

{
    package GDAP;
    # Good Dynamics Access Point
    
    my %gdap;
    # Service parameters associative array, containing:
    #   Mandatory:
    #   PCSip - The address of the Good Dynamics services access point.
    #   PCSport - The port number of the Good Dynamics services access point.
    #   pushToken - The push token, obtained by the mobile application.
    #   PCSSSL - 1 to use SSL, 0 to use a plain socket.
    #   Optional:
    #   SSL_version - SSL version selector string
    #   SSL_cipher_list - SSL cipher list string

    my $socket = undef;
    
    my $noAddress = 1;
    my $noPort = 1;
    
    sub setSSLFromPort
    {
        if ( ($gdap{PCSport} % 1000 == 443) || ($gdap{PCSport} % 1000 == 433) ) {
          $gdap{PCSSSL} = 1;
        }
        else {
          $gdap{PCSSSL} = 0;
        }
    }

    sub optsstring
    {
        return 'a:c:dnp:s:S:';
    }

    sub readopts
    {
        if ( (exists $opts{'p'}) && ($opts{'p'} =~ /[^0-9]/) ) {
            print STDERR
              'Good Dynamics services access point port apparently not numeric "',
              $opts{'p'}, "\".\n";
            return undef;
        }
        %gdap = (
            PCSip => ($opts{'a'} || 'gdmdc.good.com'),
            PCSport => 0 + ($opts{'p'} || 443),
            PCSSSL => 0
        );
        if (exists $opts{'d'}) {
            $gdap{SSL_version} = 'SSLv23:!SSLv2:!TLSv12';
            $gdap{SSL_cipher_list} = '';
        }
        if (exists $opts{'S'}) {
            $gdap{SSL_version} = $opts{'S'};
        }
        if (exists $opts{'c'}) {
            $gdap{SSL_cipher_list} = $opts{'c'};
        }
        setSSLFromPort;
        if (exists $opts{'s'}) {
            if ($opts{'s'} =~ /[^0-9]/) {
                print STDERR
                "-s parameter apparently not numeric \"$opts{'s'}\".\n";
                return undef;
            }
            my $sval = 0 + $opts{'s'};
            if ( $sval > 2 || $sval < 0 ) {
                print STDERR
                "-s parameter apparently out of range $sval.\n";
                return undef;
            }
            if ($sval < 2) {
                $gdap{PCSSSL} = $sval;
            }
        }
        $gdap{notifyOnly} = exists $opts{'n'};
        $noAddress = ! exists $opts{'a'};
        $noPort = ! exists $opts{'p'};
        return 1;
    }
    
    sub useInboundAddrIfUnset
    {
      my $inboundSocket = shift;
      
      my $ret = 0;
      
      if ($noAddress) {
        $gdap{PCSip} = $inboundSocket->peerhost();
        $ret = 1;
        print STDOUT
          'Good Proxy address set from inbound socket "', $gdap{PCSip}, "\".\n";
      }
      if ($noPort) {
        $gdap{PCSport} = 17080;
        setSSLFromPort;
      }

      return $ret;
    }
    
    sub settoken
    {
        $gdap{pushToken} = shift;
    }
    
    sub sethostparts
    {
        my $val = shift;
        if ($val ne "") {
            $gdap{PCSip} = $val;
        }
        $val = shift;
        if ($val ne "") {
            $gdap{PCSport} = $val;
        }
    }
    
    sub pushmessage
    {
        my $dump = shift;
        my $message = join $ln, @_;
        if ($dump) { print <<ONEMESSAGE; }
Sending Push Channel message:
  Service address: "$gdap{'PCSip'}"
  Service port: $gdap{'PCSport'}
  Token: "$gdap{'pushToken'}"
  Message: "$message"
ONEMESSAGE
        pushMessage($message);
    }

    # getGPServers - Send getGPServers command to a Good Proxy.
    sub getGPServers
    {
        my $cmd = join $ln,
        "GET /getGPServers?server=wrongserver.example.com&port=57251 HTTP/1.1",
        "Host: $gdap{PCSip}:$gdap{PCSport}",
        "",
        ""
        ;
        print $socket $cmd;
        return $cmd;
    }

    # checkToken - Send checkToken command to a Push Channel service.
    sub checkToken
    {
        my $cmd = join $ln,
        "GET /GNP1.0?method=checkToken HTTP/1.1",
        "Host: $gdap{PCSip}:$gdap{PCSport}",
        "X-Good-GNP-Token: $gdap{pushToken}",
        "",
        ""
        ;
        print $socket $cmd;
        return $cmd;
    }
    
    # notify - Send notify command to a Push Channel service.
    sub notify
    {
        my $payload = shift;
        my $paylen = length($payload);
        
        print $socket join $ln,
        "POST /GNP1.0?method=notify HTTP/1.1",
        "Host: $gdap{PCSip}:$gdap{PCSport}",
        "Content-Type: text/plain; charset=utf-8",
        "Content-length: $paylen",
        "X-Good-GNP-Token: $gdap{pushToken}",
        "",
        "$payload"
        ;
        print "Notifying with length $paylen\n";
    }
    
    # verifyGDAuthToken - Send GD Auth verify token command
    sub verifyGDAuthToken
    {
        my $token = shift;
        
        my @cmd = (
          "GET /verifyGDAuthToken HTTP/1.1",
          "Host: $gdap{PCSip}:$gdap{PCSport}",
          "X-Good-GD-AuthToken: $token",
          "",
          ""
        );
        print $socket join $ln, @cmd;
        
        # Dump the command too.
        print STDOUT "verifyGDAuthToken. Sending:\n";
        for(my $i=0; $i<@cmd; $i++) {
          # Skip dumping the last element if it is blank.
          next if ($i + 1 >= @cmd && $cmd[$i] eq '');
          print STDOUT sprintf("%3d", 1 + $i), ' ', $cmd[$i], "\n";
        }
        print STDOUT "\n";
    }
    
    ## consumeGNP - Read the result of a command sent to a Push Channel service.
    ## Call this after calling either of the checkToken or notify subroutines.
    #sub consumeGNP
    #{
    #    my %ret = (
    #    GNPstatus => 0, GNPstatusText => "", response => ""
    #    );
    #    
    #    while( <$socket> ) {
    #        if ( /^\s*$/ ) { last; }
    #        $ret{response} .= $_;
    #        if ( /^X-Good-GNP-Code:\s*([0-9]+)\s+([^\r\n]*)/ ) {
    #            $ret{GNPstatus} = $1;
    #            $ret{GNPstatusText} = $2;
    #        }
    #    }
    #    
    #    return %ret;
    #}
    
    ## recvDump - Reads from a socket and dumps to STDOUT. Reads until a blank
    ## line is received.
    #sub recvDump
    #{
    #    my %ret = (
    #    response => ""
    #    );
    #    
    #    print "recvDump\n";
    #    my $dumpLines = 0;
    #    
    #    for(;;) {
    #        my $sockLine = <$socket>;
    #        if (!$sockLine) {last;}
    #        $dumpLines += 1;
    #        print sprintf("%3d", $dumpLines) . " " . $sockLine;
    #        if ( $sockLine =~ /^\s*$/ ) { last; }
    #        $ret{response} .= $sockLine;
    #    }
    #    
    #    return %ret;
    #}


    sub openPCSsocket
    {
        # Open socket to communicate with the Good Dynamics services access
        # point.
        my %sockArgs = (
        PeerAddr => $gdap{PCSip}, PeerPort => $gdap{PCSport}, Proto => 'tcp'
        );
        if ( $gdap{PCSSSL} == 1 ) {
            print "\n",
              'Opening SSL socket to Good Dynamics services access point: ',
              $gdap{PCSip}, ' ', $gdap{PCSport}, " ...\n";
#            $sockArgs{SSL_verify_mode} = 0x01; # Verify peer.
            if ( exists $gdap{SSL_version}) {
                $sockArgs{SSL_version} = $gdap{SSL_version};
            }
            if ( exists $gdap{SSL_cipher_list}) {
                $sockArgs{SSL_cipher_list} = $gdap{SSL_cipher_list};
            }
            $socket = IO::Socket::SSL->new( %sockArgs );
# print STDERR 'IO::Socket::SSL::errstr() "', IO::Socket::SSL::errstr(), "\"\n";
        }
        else {
            print "\n",
              'Opening plain socket to Good Dynamics services access point: ',
              $gdap{PCSip}, ' ', $gdap{PCSport}, " ...\n";
            $socket = IO::Socket::INET->new( %sockArgs );
        }
        die
          'Could not open socket to Good Dynamics services access point. ',
          $!, "\n" unless $socket;
        
        $socket->autoflush(1);
        print "Socket to Good Dynamics services access point open\n";
    }
    
    # pushMessage - Send a Push Channel notification message.
    # This subroutine wraps up the following:
    # 1. Opening the connection to the Push Channel service, either a plain socket
    #    or an SSL connection.
    # 2. Sending a checkToken command and reading the response.
    # 3. If the token was valid, sending a notify command and reading the response.
    #
    # Parameters:
    # pushText - The payload to be sent in the Push Channel notification.
    sub pushMessage
    {
        my $pushText = pop;
        
        my $lastCmd = "";

        # Uncomment the following for a demonstrative call to getGPServers.
        # Later, this might be upgraded to actually read and use the returned
        # data.
        #openPCSsocket;
        #$lastCmd = getGPServers;
        #MINIPUSH::recvDump $socket;
        #print "getGPServers: ";
        #while (<$socket>) {
        #  print;
        #}
        #close $socket;
        #print "\n\n";
        # End of call to getGPServers
        
        my %checkTokenResp;
        if ($gdap{notifyOnly}) {
            $checkTokenResp{gnpStatus} = 100;
            print "Did not check token\n";
        }
        else {
            # Check the token.
            openPCSsocket;
            $lastCmd = checkToken;
            %checkTokenResp = MINIPUSH::recvDump($socket, 'consumeGNP');
            print "checkToken response from Push Channel service:\n" .
            "$checkTokenResp{response}\nClosing socket.\n";
            close $socket;
        }
        
        if ($checkTokenResp{gnpStatus} == 100) {
            openPCSsocket;
            
            # Send the push notification, if the token was valid or not checked.
            notify $pushText;
            my %notifyResp = MINIPUSH::recvDump($socket, 'consumeGNP'); # consumeGNP();
            print "notify response from Push Channel service:\n" .
            "$notifyResp{response}\n";
            if ($notifyResp{gnpStatus} == 100) {
                print "Push Channel message sent $notifyResp{gnpStatusText}.\n";
            }
            else {
                print
                  "Push Channel message failed $notifyResp{gnpStatus}" .
                  " \"$notifyResp{gnpStatusText}\".\nClosing socket.";
            }
            close $socket;
        }
        elsif ($checkTokenResp{gnpStatus} == 402) {
            print "Token invalid, notification skipped.\n";
        }
        else {
            print
            "Check token command failed, notification skipped. \n" .
            "Command was:\n\"$lastCmd\"\n";
        }
    }
    
    sub authToken
    {
        openPCSsocket;
        verifyGDAuthToken(shift);
        my %ret = MINIPUSH::recvDump($socket, 'recvAuthToken');
        close $socket;
        return %ret;
    }
}

{
    package ROL;
    # Run On Listen
    
    my $localOverride;

    sub readopts
    {
        $localOverride = (exists $opts{'l'});
        return 1;
    }

    sub optsstring
    {
        return 'l';
    }

    sub runOnListen
    {
        my $run = shift;
        my $port = (shift || "");
        
        # Create associative array to hold parameters to the listen socket
        my %sockArgs = ( Proto => 'tcp', Listen => 1, Reuse => 1 );
        if ( $port ne "" ) { $sockArgs{LocalPort} = $port; }
        
        print "\nOpening listen socket: $port...\n";
        my $listenSock = new IO::Socket::INET( %sockArgs );
        die "Could not create listen socket: $!\n" unless $listenSock;
        
        my $localIP;
        if ($localOverride) {
            $localIP = "127.0.0.1";
        }
        else {
            # Get the local system's IP address
            $localIP = Net::Address::IP::Local->public;
            # If the server seems to crash here, try specifying -l, which
            # turns on localOverride.
        }
        
        # Print the address and port number in a number of formats for ease of
        # copying and pasting into different places
        my $portno = $listenSock->sockport();
        print "Listen socket open\n" .
        "$localIP:$portno\n" .
        "[[GDSocket alloc] init:\"$localIP\" onPort:$portno" .
        " andUseSSL:NO];\n" .
        "[NSMutableURLRequest requestWithURL:[NSURL URLWithString:" .
        "@\"http://$localIP:$portno\"]];\n" .
        "connect(\"$localIP\", $portno, 0);\n" .
        "\n" ;
        
        # Now loop forever, waiting for connections from clients
        my $acceptSock;
        while( $acceptSock = $listenSock->accept() ) {
            $acceptSock->autoflush(1);
            my $peerAddress = $acceptSock->peerhost();
            my $peerPort = $acceptSock->peerport();
            print "Client connection \"", $peerAddress, "\" ", $peerPort, "\n";
            print "Sleeping for 1s ...\n";
            sleep 1;
            print "Awake\n";
            
            # If the run subroutine returns true then close the socket.
            # Otherwise, it has to close the socket itself.
            if ( &$run($acceptSock) ) {
                close $acceptSock;
                print "Closed\n\n";
            }
        }
    }

}

# main - Entry point to the whole server.
sub main
{
    # If -u was specified then print the usage and quit
    if ( exists $opts{'u'} ) {
      usage;
      return;
    }
    # If -U was specified then print the help and quit
    if ( exists $opts{'U'} ) {
      help;
      return;
    }
    if (!GDAP::readopts()) {
        usage;
        return;
    }

    my $modeOpt = shift || "";

    my %modes;
    
    # Table of modes follows. Each mode is defined in terms of:
    # 'proc' A subroutine to execute.
    # 'listen' a flag:
    # If present, means that the subroutine is executed in the context of a
    # listen socket, and:
    # - Takes an accept socket as a parameter.
    # - Returns true if the accept socket should be closed.
    # - Returns false if the accept socket should not be closed, implying that
    #   the subroutine has already closed it.
    #
    # If absent, means that the subroutine is executed standalone, with no
    # listen socket having been opened, and:
    # - Takes any remaining command line parameters as its parameters.
    # The return value is ignored in that case.
    #
    $modes{'one'}{'proc'} = sub {
        GDAP::settoken( shift || "" );
        GDAP::pushmessage( (0==0), @_ );
    };

    $modes{'auth'}{'proc'} = sub {
        GDAP::authToken( shift || "" );
    };

    $modes{'push'}{'proc'} = sub {
        my $acceptSock = shift;
        # Receive minipush parameters from the client
        my %mpp = recvMinipush $acceptSock;
        GDAP::settoken( $mpp{'pushToken'} );
        # If the address and port for the service were specified by
        # the client, use those values.
        GDAP::sethostparts( $mpp{'PCSip'}, $mpp{'PCSport'} );
        
        close $acceptSock;
        print "Closed\n\n";
        if ($mpp{notificationCount} == 0) {
            GDAP::pushMessage( (0!=0), "Notification 0: " . localtime );
        }
        else {
            for( my $i=1; $i<=$mpp{notificationCount}; $i++ ) {
                if ($mpp{notificationDelay} > 0) {
                    print "Sleeping for $mpp{notificationDelay}s ...\n";
                    sleep $mpp{notificationDelay};
                }
                GDAP::pushMessage( (0!=0), "Notification $i: " . localtime );
            }
        }
        return (1==0);
    };
    $modes{'push'}{'listen'} = 1;

    $modes{'sockum'}{'proc'} = sub {
        my $acceptSock = shift;
        my %sockum = recvSockum $acceptSock;
        sendSockum $acceptSock, %sockum;
        return (0==0);
    };
    $modes{'sockum'}{'listen'} = 1;

    $modes{'authserv'}{'proc'} = sub {
        my $acceptSock = shift;
        GDAUTH::authserv $acceptSock;
        return 1;
    };
    $modes{'authserv'}{'listen'} = 1;

    $modes{'http404'}{'proc'} = sub {
        my $acceptSock = shift;
        # Dump whatever HTTP was received, then send a minimal 404
        HTTP::recvHTTP $acceptSock;
        HTTP::http404Sock $acceptSock;
        return (0==0);
    };
    $modes{'http404'}{'listen'} = 1;
    
    if (!$modes{$modeOpt}{'proc'}) {
        print STDERR "Unknown mode \"$modeOpt\".\n";
        usage;
        return;
    }
    my $mode_sub = $modes{$modeOpt}{'proc'};

    if (exists $modes{$modeOpt}{'listen'}) {
        my $listenPort = shift || "";
        if ( $listenPort =~ /[^0-9]/ ) {
            print STDERR
                "Listener port apparently not numeric \"$listenPort\".\n";
            usage;
            return;
        }
        
        if (!ROL::readopts()) {
            usage;
            return;
        }

        # Following subroutine does not return
        ROL::runOnListen( $mode_sub, $listenPort );
    }
    else {
        &$mode_sub(@_);
    }
}

# Read the command line switches
getopts( GDAP::optsstring() . ROL::optsstring() . 'uU', \%opts );

# Start the server
main( @ARGV );
