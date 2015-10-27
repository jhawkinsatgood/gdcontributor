/* Copyright (c) 2015 Good Technology Corporation
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

#import "DemoProvideTransferFile.h"
#import "GdcServiceProviderTransferFile.h"
#import "DemoUtility.h"
#import <GD/GDFileSystem.h>

@interface DemoProvideTransferFile ()
@property (nonatomic) GdcServiceProviderTransferFile *provider;
@end

@implementation DemoProvideTransferFile

@synthesize demoExecuteLabel;

-(instancetype)init
{
    self = [super init];
    demoExecuteLabel = nil;
    return self;
}

-(NSString *)demoExecuteOrPickList
{
    return nil;
}

-(void)demoLoad
{
    if (!self.demoUserInterface) {
        assert("DemoProvideTransferFile set up attempted without user "
               "interface. Call demoSetUserInterface before demoSetUp.");
    }
    if (self.provider == nil) {
        self.provider = [GdcServiceProviderTransferFile new];
    }
    
    DemoProvideTransferFile * __weak weakSelf = self;

    [self.provider addListener:^(GdcServiceRequest *request) {
        NSString *filename = [request getAttachment];

        [weakSelf.demoUserInterface
         demoLogFormat:@"%@ received file \"%@\"...\n",
         NSStringFromClass([DemoProvideTransferFile class]), filename];
        
        // Stat the file ...
        [weakSelf.demoUserInterface
         demoLogFormat:@"%@", [DemoUtility statFile:filename]];
        
        // ... and then dump some initial bytes. The program assumes
        // the bytes are printable, by demoLogFormat.
        [weakSelf.demoUserInterface
         demoLogFormat:@"%@", [DemoUtility byteDump:filename]];
        
        // Enable propagation, in case there is another listener.
        return request;
    }];

    [self.demoUserInterface
     demoLogFormat:@"Ready for: %@\n", self.provider.serviceID];
}

@end
