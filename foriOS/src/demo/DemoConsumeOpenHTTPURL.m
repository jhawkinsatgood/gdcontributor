/* Copyright (c) 2016 Good Technology Corporation
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

#import "DemoConsumeOpenHTTPURL.h"
#import "GdcServiceRequestOpenHTTPURL.h"

@interface DemoConsumeOpenHTTPURL()
@property (nonatomic) GdcServiceRequestOpenHTTPURL *request;
@end

@implementation DemoConsumeOpenHTTPURL

@synthesize demoExecuteLabel;

-(instancetype)init
{
    self = [super init];
    demoExecuteLabel = @"Open HTTP URL";
    return self;
}

-(NSArray *)demoExecuteOrPickList {
    if (self.request == nil) { self.request = [GdcServiceRequestOpenHTTPURL new]; }
    return [[self.request queryProviders] getProviderNames];
}

-(void)demoPickAndExecute:(int)pickListIndex
{
    // Send the request.
    [[[self.request selectProvider:pickListIndex]
      setURL:@"https://intranet"]
     sendOrMessage:nil];
    // The above returns a message if there is an error in the send. The
    // message is also inserted into the Request object, which is dumped
    // below, so there is no need to log it additionally.
    [self.demoUserInterface demoLogFormat:@"Sent request:%@\n", self.request];

    return;
}

@end
