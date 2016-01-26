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

#import <GD/GDFileManager.h>

#import "DemoProvidePlayBackgroundSound.h"
#import "GdcServiceProviderPlayBackgroundSound.h"

#import "BackgrounderForGoodDynamics.h"

#import "DemoUtility.h"

@interface DemoProvidePlayBackgroundSound ()
@property (nonatomic, strong) GdcServiceProviderPlayBackgroundSound *provider;
@end

@implementation DemoProvidePlayBackgroundSound
@synthesize demoExecuteLabel;

static id<DemoUserInterface> demoProvidePlayBackgroundSoundUserInterface = nil;

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

static void demoProvidePlayBackgroundSoundLogger(NSString *message)
{
    
    [demoProvidePlayBackgroundSoundUserInterface
     demoLogFormat:@"%@ %@", [DemoUtility simpleDate], message];
}

-(void)demoLoad
{
    if (!self.demoUserInterface) {
        assert("DemoProvidePlayBackgroundSound set up attempted without user "
               "interface. Call demoSetUserInterface before demoSetUp.");
    }
    
    DemoProvidePlayBackgroundSound * __weak weakSelf = self;

    if (self.provider == nil) {
        self.provider = [GdcServiceProviderPlayBackgroundSound new];
    }
    demoProvidePlayBackgroundSoundUserInterface = self.demoUserInterface;
    demoProvidePlayBackgroundSoundLogger(@"Setting logger.\n");
    [[Backgrounder sharedInstance]
     setLogger:demoProvidePlayBackgroundSoundLogger];
    [self.provider addListener:^(GdcServiceRequest *request) {
        NSString *inFilename = [request getAttachment];
        [weakSelf.demoUserInterface demoLogFormat:@"%@ received file \"%@\"...\n",
         NSStringFromClass([DemoProvidePlayBackgroundSound class]), inFilename];
        
        // Stat the file ...
        [weakSelf.demoUserInterface
         demoLogFormat:@"%@", [DemoUtility statFile:inFilename]];
        
        // ... and then dump some initial bytes. The program assumes
        // the bytes are printable, by demoLogFormat.
        [weakSelf.demoUserInterface
         demoLogFormat:@"%@", [DemoUtility byteDump:inFilename]];
        
        NSURL *inURL = [NSURL fileURLWithPath:inFilename];
        NSString *outDirectory = request.application;

        NSError *error;
        BOOL outIsDir;
        BOOL createDir = NO;
        GDFileManager *gdFileManager = [GDFileManager defaultManager];
        if ([gdFileManager fileExistsAtPath:outDirectory
                               isDirectory:&outIsDir] )
        {
            if (!outIsDir) {
                createDir = YES;
                if (![gdFileManager removeItemAtPath:outDirectory
                                               error:&error] )
                {
                    [weakSelf.demoUserInterface
                     demoLogFormat:@"%s Failed to delete file \"%@\". %@.\n",
                     __PRETTY_FUNCTION__, outDirectory, error];
                }
            }
        }
        else {
            createDir = YES;
        }
        
        if (createDir) {
            if (![gdFileManager createDirectoryAtPath:outDirectory
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error] )
            {
                [weakSelf.demoUserInterface
                 demoLogFormat:@"%s Failed to create directory \"%@\". %@.\n",
                 __PRETTY_FUNCTION__, outDirectory, error];
            }
        }
        
        NSURL *outURL =
        [NSURL fileURLWithPathComponents:@[outDirectory,
                                           [inURL lastPathComponent] ]];
        NSString *outFilename = [outURL path];
        
        if ([gdFileManager moveItemAtPath:inFilename
                                   toPath:outFilename
                                    error:&error] )
        {
            [weakSelf.demoUserInterface demoLogFormat:
             @"%s Moved attachment from \"%@\" to \"%@\" OK.\n",
             __PRETTY_FUNCTION__, inFilename, outFilename];
        }
        else {
            [weakSelf.demoUserInterface demoLogFormat:
             @"%s Failed to move attachment from \"%@\" to \"%@\". %@.\n",
             __PRETTY_FUNCTION__, inFilename, outFilename, error];
        }

        [[Backgrounder sharedInstance]
         setLogger:demoProvidePlayBackgroundSoundLogger];
        [weakSelf.demoUserInterface demoLogFormat:@"gdStartPath %@",
         [BackgrounderForGoodDynamics
          gdStartPlayback:outFilename
          in:[Backgrounder sharedInstance]] ?
         @"OK" :
         @"Failed"];

        // Enable propagation, in case there is another listener.
        return request;
    }];
    
    [self.demoUserInterface
     demoLogFormat:@"Ready for: %@\n", self.provider.serviceID];
}


@end
