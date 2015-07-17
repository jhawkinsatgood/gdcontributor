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

#import <GD/GDFileSystem.h>

#import "DemoProvidePlayBackgroundSound.h"
#import "gdProviderPlayBackgroundSound.h"

#import "BackgrounderForGoodDynamics.h"

#import "DemoUtility.h"

@interface DemoProvidePlayBackgroundSound ()
@property (nonatomic, strong) gdProviderPlayBackgroundSound *provider;
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
    if (!DEMOUI) {
        assert("DemoProvidePlayBackgroundSound set up attempted without user "
               "interface. Call demoSetUserInterface before demoSetUp.");
    }
    if (self.provider == nil) {
        self.provider = [gdProviderPlayBackgroundSound new];
    }
    demoProvidePlayBackgroundSoundUserInterface = DEMOUI;
    demoProvidePlayBackgroundSoundLogger(@"Setting logger.\n");
    [[Backgrounder sharedInstance]
     setLogger:demoProvidePlayBackgroundSoundLogger];
    [self.provider addListener:^(gdRequest *request) {
        NSString *inFilename = [request getAttachment];
        [DEMOUI demoLogFormat:@"%@ received file \"%@\"...\n",
         NSStringFromClass([DemoProvidePlayBackgroundSound class]), inFilename];
        
        // Stat the file ...
        [DEMOUI demoLogFormat:@"%@", [DemoUtility statFile:inFilename]];
        
        // ... and then dump some initial bytes. The program assumes
        // the bytes are printable, by demoLogFormat.
        [DEMOUI demoLogFormat:@"%@", [DemoUtility byteDump:inFilename]];
        
        NSURL *inURL = [NSURL fileURLWithPath:inFilename];
        NSString *outDirectory = [request getApplication];

        NSError *error;
        BOOL outIsDir;
        BOOL createDir = NO;
        if ([GDFileSystem fileExistsAtPath:outDirectory
                               isDirectory:&outIsDir] )
        {
            if (!outIsDir) {
                createDir = YES;
                if (![GDFileSystem removeItemAtPath:outDirectory
                                              error:&error] )
                {
                    [DEMOUI
                     demoLogFormat:@"%s Failed to delete file \"%@\". %@.\n",
                     __PRETTY_FUNCTION__, outDirectory, error];
                }
            }
        }
        else {
            createDir = YES;
        }
        
        if (createDir) {
            if (![GDFileSystem createDirectoryAtPath:outDirectory
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error] )
            {
                [DEMOUI
                 demoLogFormat:@"%s Failed to create directory \"%@\". %@.\n",
                 __PRETTY_FUNCTION__, outDirectory, error];
            }
        }
        
        NSURL *outURL =
        [NSURL fileURLWithPathComponents:@[outDirectory,
                                           [inURL lastPathComponent] ]];
        NSString *outFilename = [outURL path];
        
        if ([GDFileSystem moveItemAtPath:inFilename
                              toPath:outFilename
                               error:&error] )
        {
            [DEMOUI demoLogFormat:
             @"%s Moved attachment from \"%@\" to \"%@\" OK.\n",
             __PRETTY_FUNCTION__, inFilename, outFilename];
        }
        else {
            [DEMOUI demoLogFormat:
             @"%s Failed to move attachment from \"%@\" to \"%@\". %@.\n",
             __PRETTY_FUNCTION__, inFilename, outFilename, error];
        }

        
        
        [DEMOUI demoLogFormat:@"gdStartPath %@",
         [BackgrounderForGoodDynamics
          gdStartPath:outFilename
          logger:demoProvidePlayBackgroundSoundLogger] ?
         @"OK" :
         @"Failed"];

        // Enable propagation, in case there is another listener.
        return request;
    }];
    
    [DEMOUI demoLogFormat:@"Ready for: %@\n", [self.provider getServiceID]];
}


@end
