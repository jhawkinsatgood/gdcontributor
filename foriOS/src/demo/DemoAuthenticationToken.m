/* Copyright (c) 2014 Good Technology Corporation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "DemoAuthenticationToken.h"

#import <GD/GDiOS.h>
#import <GD/GDAppServer.h>

NS_ENUM(NSInteger, DemoAuthenticationTokenState) {
    DemoAuthenticationTokenNone,
    DemoAuthenticationTokenAwaitingChallenge,
    DemoAuthenticationTokenAwaitingVerification,
    DemoAuthenticationTokenOK,
    DemoAuthenticationTokenFailed
};

@interface DemoAuthenticationToken()
@property (nonatomic) GDSocket* gdSocket;
@property (strong, nonatomic) GDUtility *gdUtility;
@property (assign) enum DemoAuthenticationTokenState state;
@property (strong, nonatomic) GDAppServer *gdAppServer0;
@end

@implementation DemoAuthenticationToken

@synthesize demoExecuteLabel;

-(instancetype)init
{
    self = [super init];
    demoExecuteLabel = @"Authentication Token";
    _state = DemoAuthenticationTokenNone;
    return self;
}

-(NSArray *)demoExecuteOrPickList
{
    
    NSDictionary *appConfig = [[GDiOS sharedInstance] getApplicationConfig];
    NSArray *gdAppServers = [appConfig objectForKey:GDAppConfigKeyServers];
    
    if (gdAppServers == nil || gdAppServers.count < 1) {
        self.gdAppServer0 = nil;
    }
    else {
        self.gdAppServer0 = gdAppServers[0];
    }
    
    if (self.gdAppServer0 == nil) {
        [DEMOUI demoLogString:@"No server addresses configured.\n"];
        return nil;
    }

    // Initialise GD Auth utility
    if (self.gdUtility == nil) {
        self.gdUtility = [[GDUtility alloc] init];
        self.gdUtility.gdAuthDelegate = self;
    }
    
    const char *server = [self.gdAppServer0.server
                          cStringUsingEncoding:NSASCIIStringEncoding];
    int port = [self.gdAppServer0.port intValue];
    
    [DEMOUI demoLogFormat:@"Socket creation \"%s\" %d ...\n", server, port];
    self.gdSocket = [[GDSocket alloc] init:server
                                    onPort:port
                                 andUseSSL:NO];
    self.gdSocket.delegate = self;
    [DEMOUI demoLogString:@"Socket connect...\n"];
    [self.gdSocket connect];
    [DEMOUI demoLogString:@"Socket connecting...\n"];

    return nil;
}

-(void)onOpen:(id)socket_id {
    [DEMOUI demoLogString:@"Socket open. Loading stream...\n"];
    GDSocket *socket = (GDSocket *)socket_id;
    [socket.writeStream write:"CHALLENGE\n"];
    [DEMOUI demoLogString:@"Socket stream writing...\n"];
    self.state = DemoAuthenticationTokenAwaitingChallenge;
    [socket write];
    [DEMOUI demoLogString:@"Socket stream written.\n"];
}

-(void)onRead:(id) socket_id {
    [DEMOUI demoLogString:@"DemoAuthenticationToken socket reading...\n"];
    GDSocket *socket = (GDSocket *) socket_id;
    NSString *str = [socket.readStream unreadDataAsString];
    [DEMOUI demoLogFormat:@"Received data \"%@\"\n", str];
    
    switch (self.state) {
        case DemoAuthenticationTokenNone:
        case DemoAuthenticationTokenFailed:
        case DemoAuthenticationTokenOK:
            [DEMOUI demoLogString:@"Not expecting to receive.\n"];
            break;
            
        case DemoAuthenticationTokenAwaitingChallenge: {
            // Recevied challenge string from server.
            //
            // The data will include an end-of-line. Find where it is so that
            // it can be excluded from the challenge string in the request.
            unsigned int end;
            [str getLineStart:NULL end:NULL contentsEnd:&end
                     forRange:NSMakeRange(0, 1)];
            //
            // Request a token.
            [self.gdUtility getGDAuthToken:[str substringToIndex:end]
                                serverName:self.gdAppServer0.server];
            // Processing will continue in an onGDAuthToken... callback
        } break;
            
        case DemoAuthenticationTokenAwaitingVerification:
            // Check if the first character is O from OK
            if ([[str substringToIndex:1] isEqualToString:@"O"]) {
                self.state = DemoAuthenticationTokenOK;
                [DEMOUI demoLogString:@"Token verified.\n"];
            }
            else {
                self.state = DemoAuthenticationTokenFailed;
                [DEMOUI demoLogString:@"Token rejected.\n"];
            }
            break;
    }
    
    BOOL allDataHasBeenReceived = NO;
    // Code to read the received data and determine whether all the data has
    // been received would go here. For the demo, assume all data is received in
    // a single read.
    if (allDataHasBeenReceived) {
        [DEMOUI demoLogString:@"Socket disconnecting...\n"];
        [socket disconnect];
    }
}

-(void)onClose:(id) socket {
    [DEMOUI demoLogString:@"DemoAuthenticationToken socket closed.\n"];
}

- (void)onErr:(int)error inSocket:(id) socket {
    [DEMOUI demoLogFormat:@"DemoAuthenticationToken socket error %d\n", error];
}

- (void)onGDAuthTokenSuccess:(NSString *)gdAuthToken
{
    [DEMOUI demoLogFormat:@"onGDAuthTokenSuccess \"%@\"\n", gdAuthToken];
    [self.gdSocket.writeStream write:"TOKEN\n"];
    // To force an error, uncomment the following line.
    // gdAuthToken = [gdAuthToken substringFromIndex:2];
    [self.gdSocket.writeStream
     write:[gdAuthToken cStringUsingEncoding:NSASCIIStringEncoding]];
    [self.gdSocket.writeStream write:"\n\n"];
    [DEMOUI demoLogString:@"Socket stream writing...\n"];
    self.state = DemoAuthenticationTokenAwaitingVerification;
    [self.gdSocket write];
    [DEMOUI demoLogString:@"Socket stream written.\n"];
}

- (void)onGDAuthTokenFailure:(NSError *)err
{
    [DEMOUI demoLogFormat:@"onGDAuthTokenFailure \"%@\"\n", err];
    self.state = DemoAuthenticationTokenNone;
}

@end
