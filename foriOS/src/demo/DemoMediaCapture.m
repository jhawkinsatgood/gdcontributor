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

#import "DemoMediaCapture.h"
#import "DemoUtility.h"

#import <GD/GDFileManager.h>
#import <GD/GDAppServer.h>

#import "Backgrounder.h"
#import "BackgrounderForGoodDynamics.h"
#import "GdcRuntimeDispatcher.h"

#import "AVCamViewController.h"

@interface DemoMediaCapture()
@property (readonly)NSString *kRecordingsDirectory;
@property (readonly)NSString *kPhotosDirectory;

@property (nonatomic)DemoPanelItem *stopItem;
@property (nonatomic)NSArray *stopItemLocation;

@property (nonatomic)NSString *uploadURL;
@property (assign, nonatomic)BOOL observingConfiguration;
@end

@implementation DemoMediaCapture

static id<DemoUserInterface> demoMediaCaptureUserInterface = nil;

-(instancetype)init
{
    self = [super init];
    
    _gdcCommunication = [[GdcCommunication alloc] init];
    _kPhotosDirectory = [[DemoUtility documentsDirectory]
                         stringByAppendingPathComponent:@"photos"];
    _kRecordingsDirectory =[[DemoUtility documentsDirectory]
                            stringByAppendingPathComponent:@"recordings"];
    
    return self;
}

static void demoMediaCaptureLogger(NSString *message)
{
    [demoMediaCaptureUserInterface
     demoLogFormat:@"%@ %@", [DemoUtility simpleDate], message];
}

-(void)addStopItem
{
    self.stopItemLocation = [self appendToDivision:0 item:self.stopItem];
}
-(void)removeStopItem
{
    if (self.stopItemLocation == nil) return;

    NSMutableArray *division =
    self.demoPanelItemDivisions[[self.stopItemLocation[0] intValue]];
    
    [division removeObjectAtIndex:[self.stopItemLocation[1] intValue]];
    self.stopItemLocation = nil;
    
    [self demoPanelLoad:YES];
}

-(DemoPanelItem *)audioRecordingIn:(NSString *)directory
{
    DemoMediaCapture * __weak weakSelf = self;
    
    DemoPanelItemClick clickBlock = DEMOPANELITEMCLICK(demoPanelItem) {
        NSString *path = [DemoUtility numberedFileIn:directory
                                                stub:@"capture"
                                           extension:@"aiff"];
        if (path == nil) {
            [self.demoUserInterface demoLogFormat:
             @"Couldn't generate numbered file in \"%@\".\n", directory];
            return;
        }
        [weakSelf addStopItem];
        [BackgrounderForGoodDynamics
         gdStartRecording:path
         in:[Backgrounder sharedInstance] ];
    };
    
    return [DemoPanelItem
            demoPanelItemOfType:DemoPanelItemTypeCommandOn
            label:@"Record"
            clickBlock:clickBlock];
}

-(DemoPanelItem *)cameraStoringIn:(NSString *)directory
{
    DemoMediaCapture * __weak weakSelf = self;
//    NSString *path = nil;
    
    DemoPanelItemClick clickBlock = DEMOPANELITEMCLICK(demoPanelItem) {
        NSString *path = [DemoUtility numberedFileIn:directory
                                                stub:@"capture"
                                           extension:@"jpeg"];
        if (path == nil) {
            [self.demoUserInterface demoLogFormat:
             @"Couldn't generate numbered file in \"%@\".\n", directory];
        }
        else {
            // Set up the prepare block, which will tell the camera preview
            // which control needs to be refreshed after the picture has been
            // taken.
            self.demoPanelSegueBlock = DEMOPANELSEQUEBLOCK(segue) {
                AVCamViewController *avCamViewController =
                (AVCamViewController *)segue.destinationViewController;
                
                avCamViewController.demoMediaCapture = weakSelf;
                avCamViewController.capturePath = path;
            };
            
            [self.demoUserInterface segueToSecondViewFrom:self];
        }
    };
    
    return [DemoPanelItem
            demoPanelItemOfType:DemoPanelItemTypeCommandOn
            label:@"Camera"
            clickBlock:clickBlock];
}

-(void)observeConfiguration
{
    if (self.observingConfiguration) return;
    
    [[GdcRuntimeDispatcher sharedInstance]
     addObserverForApplicationConfiguration:
     GDC_CONFIGURATION_OBSERVER(configDictionary, configString) {
         NSArray *servers =
         [configDictionary objectForKey:GDAppConfigKeyServers];
         GDAppServer *gdAppServer = (GDAppServer *)servers[0];
         NSString *newUploadURL = [NSString stringWithFormat:@"http://%@:%@",
                                  gdAppServer.server, gdAppServer.port];
         if (self.uploadURL == nil ||
             ![self.uploadURL isEqualToString:newUploadURL] )
         {
             self.uploadURL = newUploadURL;
             [self.demoUserInterface
              demoLogFormat:@"Will upload to \"%@\"\n", self.uploadURL];
         }
         
     } andInvokeNow:YES];

    self.observingConfiguration = YES;
}

-(void)listMediaDirectory:(NSString *)path withPlayButtons:(BOOL)withPlay
{
    NSError *error = nil;
    GDFileManager *gdFileManager = [GDFileManager defaultManager];

    BOOL isDirectory = NO;
    if ([gdFileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        if (!isDirectory) {
            // Path exists but isn't a directory. Delete it.
            if (![gdFileManager removeItemAtPath:path error:&error]) {
                [self.demoUserInterface
                 demoLogFormat:@"Failed to delete non-directory \"%@\". %@.\n",
                 path, error];
            }
            // Next if will create a directory instead.
        }
        
        // Else: It was a directory, do nothing.
        
    }
    else {
        isDirectory = NO;
    }

    if (!isDirectory) {
        if ([gdFileManager createDirectoryAtPath:path
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&error])
        {
            [self.demoUserInterface
             demoLogFormat:@"Created directory \"%@\"\n", path];
        }
        else {
            [self.demoUserInterface
             demoLogFormat:@"Failed to  create directory \"%@\". %@.\n",
             path, error];
        }
        
    }
    
    error = nil;
    NSArray *listing = [[gdFileManager contentsOfDirectoryAtPath:path
                                                           error:&error]
                         sortedArrayUsingComparator:
                         ^NSComparisonResult(id obj1, id obj2) {
                             return [(NSString *)obj1 compare:(NSString *)obj2];
                         }];
    
    if (listing != nil) for (int index=0; index<listing.count; index++) {
        NSString *listingi = listing[index];
        NSString *pathi = [path stringByAppendingPathComponent:listingi];
        long division =
        [self addDivisionWithItem:[DemoPanelItem
                                   demoPanelItemLabel:listingi]];
        
        if (withPlay) {
            [self
             appendToDivision:division
             item:[DemoPanelItem
                   demoPanelItemOfType:DemoPanelItemTypeCommandOn
                   label:@"Play"
                   clickBlock:DEMOPANELITEMCLICK(demoPanelItem) {
                       [self addStopItem];
                       [BackgrounderForGoodDynamics
                        gdStartPlayback:pathi
                        in:[Backgrounder sharedInstance]];
                       
                   }]];
        }
        
        [self
         appendToDivision:division
         item:[DemoPanelItem
               demoPanelItemOfType:DemoPanelItemTypeCommandOn
               label:@"Upload"
               clickBlock:DEMOPANELITEMCLICK(demoPanelItem) {
                   [self.gdcCommunication upload:pathi
                                              to:self.uploadURL];
               }]
         ];
        
        [self
         appendToDivision:division
         item:[DemoPanelItem demoPanelItemLabel:[DemoUtility
                                                 statFile:pathi]]
         ];

        [self
         appendToDivision:division
         item:[DemoPanelItem
               demoPanelItemOfType:DemoPanelItemTypeCommandOn
               label:@"Delete"
               clickBlock:DEMOPANELITEMCLICK(demoPanelItem) {
                   NSError *blockError = nil;
                   if (![gdFileManager removeItemAtPath:pathi
                                                  error:&blockError])
                   {
                       [self.demoUserInterface
                        demoLogFormat:@"Failed to delete \"%@\". %@.\n",
                        pathi, blockError];
                   }
                   [self demoPanelLoad:YES];
               }]
         ];
        
    }
    
    if (error != nil) {
        [self.demoUserInterface
         demoLogFormat:@"Failed to list directory \"%@\". %@.\n",
         path, error];
    }
}

-(void)demoPanelLoad:(BOOL)andRefresh
{
    DemoMediaCapture * __weak weakSelf = self;
    
    demoMediaCaptureUserInterface = [self demoUserInterface];
    [[Backgrounder sharedInstance] setLogger:demoMediaCaptureLogger];

    [weakSelf observeConfiguration];
    
    self.gdcCommunication.logger = GDC_COMMUNICATION_LOGGER(message) {
        [weakSelf.demoUserInterface
         demoLogFormat:@"%@ %@", [DemoUtility simpleDate], message];
    };

    if (self.stopItem == nil) {
        self.stopItem = [DemoPanelItem
                         demoPanelItemOfType:DemoPanelItemTypeCommandBack
                         label:@"Stop"
                         clickBlock:DEMOPANELITEMCLICK(demoPanelItem){
                             [[Backgrounder sharedInstance] stop];
                             [weakSelf removeStopItem];
                         }];
    }
    
    [self deleteAllDivisions];
    
    [self addDivisionWithArray:
     @[ [DemoPanelItem demoPanelItemLabel:@"Media Capture"],
        [weakSelf audioRecordingIn:self.kRecordingsDirectory],
        [weakSelf cameraStoringIn:self.kPhotosDirectory] ]
     ];
    
    [weakSelf listMediaDirectory:self.kPhotosDirectory withPlayButtons:NO];
    [weakSelf listMediaDirectory:self.kRecordingsDirectory withPlayButtons:YES];
    
    if (andRefresh) {
        [self.demoUserInterface refresh];
    }
    
}

@end