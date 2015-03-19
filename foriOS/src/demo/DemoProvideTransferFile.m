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

#import "DemoProvideTransferFile.h"
#import "gdProviderTransferFile.h"
#import "DemoUtility.h"
#import <GD/GDFileSystem.h>

@interface DemoProvideTransferFile ()
@property (nonatomic, strong) gdProviderTransferFile *provider;
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
    if (!DEMOUI) {
        assert("DemoProvideTransferFile set up attempted without user "
               "interface. Call demoSetUserInterface before demoSetUp.");
    }
    if (self.provider == nil) {
        self.provider = [gdProviderTransferFile new];
    }
    [self.provider addListener:^(gdRequest *request) {
        NSString *filename = [request getAttachment];

        [DEMOUI demoLogFormat:@"%@ received file \"%@\"...\n",
         NSStringFromClass([DemoProvideTransferFile class]), filename];
        
        // Stat the file ...
        [DEMOUI demoLogFormat:@"%@", [DemoUtility statFile:filename]];
        
        // ... and then dump some initial bytes. The program assumes
        // the bytes are printable, by demoLogFormat.
        [DEMOUI demoLogFormat:@"%@", [DemoUtility byteDump:filename]];
        
        // Enable propagation, in case there is another listener.
        return request;
    }];

    [DEMOUI demoLogFormat:@"Ready for: %@\n", [self.provider getServiceID]];
}

@end
