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

#import "DemoConsumeOpenShareURL.h"
#import "gdRequestOpenShareURL.h"

@interface DemoConsumeOpenShareURL()
@property (strong, nonatomic) gdRequestOpenShareURL *request;
@end

@implementation DemoConsumeOpenShareURL

@synthesize demoExecuteLabel;

-(instancetype)init
{
    self = [super init];
    demoExecuteLabel = @"Open Share URL";
    return self;
}

-(NSArray *)demoExecuteOrPickList {
    if (self.request == nil) { self.request = [gdRequestOpenShareURL new]; }
    return [[self.request queryProviders] getProviderNames];
}

-(void)demoPickAndExecute:(int)pickListIndex
{
    // Send the request.
    [self.request selectProvider:pickListIndex];
//    [self.request setURL:@"https://hub.corp.good.com/architecture-public/"
//    "SitePages/Home.aspx"];
    [self.request
     setURL:@"https://hub.corp.good.com/architecture-public/"
     "Shared%20Documents?GoodShareAction=open&version=1&splitLoc=45&c=F573"];
    [self.request sendOrMessage:nil];
    // The above returns a message if there is an error in the send. The
    // message is also inserted into the Request object, which is dumped
    // below, so there is no need to log it additionally.
    if (DEMOUI) [DEMOUI demoLogFormat:@"Sent request:%@\n", self.request];
    
    return;
}

@end
