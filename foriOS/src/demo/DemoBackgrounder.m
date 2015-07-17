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

#import "DemoBackgrounder.h"
#import "DemoUtility.h"

#import "Backgrounder.h"
#import "Telephony.h"

#include <GD/GD_C_FileSystem.h>
#include <stdio.h>

@interface ListItem: NSObject
@property (strong, nonatomic) NSString *label;
@property (strong, nonatomic) NSString *path;
@end

@implementation ListItem

-(instancetype)initWithLabel:(NSString *)label
{
    self.label = label;
    self.path = nil;
    return self;
}

-(instancetype)initWithPath:(NSString *)path
{
    self.path = path;
    self.label = [[NSURL fileURLWithPath:self.path] lastPathComponent];
    return self;
}

-(NSString *)description
{
    return self.label;
}

-(BOOL)hasPath
{
    return self.path != nil;
}

@end

@interface DemoBackgrounder()
@property (strong, nonatomic) NSArray *list;
@property (strong, nonatomic) Telephony *telephony;
@property (strong, nonatomic) NSString *last_message;
@end

@implementation DemoBackgrounder

@synthesize demoExecuteLabel;
static id<DemoUserInterface> demoBackgrounderUserInterface = nil;

-(instancetype)init
{
    self = [super init];
    demoExecuteLabel = @"Backgrounder";
    return self;
}

-(NSArray *)demoExecuteOrPickList {
    NSMutableArray *list_builder = [NSMutableArray new];
    [list_builder
     addObjectsFromArray:@[[[ListItem alloc] initWithLabel:@"Stop"],
                           [[ListItem alloc] initWithLabel:@"Telephony"] ]];
    
    NSArray *resource_list =
    [[NSBundle mainBundle] pathsForResourcesOfType:nil
                                       inDirectory:@"sounds"];
    for (NSString *listi in resource_list) {
        [list_builder addObject:[[ListItem alloc] initWithPath:listi]];
    }
    
    self.list = [NSArray arrayWithArray:list_builder];
    
    return self.list;
}

static void demoBackgrounderLogger(NSString *message)
{
    // ToDo in order to create log files instead of just putting it in the UI:
    // Work out if a new file has to be created, based on file stat.
    // Create it if needed. Write some user and application details to it.
    //
    // Open for appending.
    // Write the timestamp, simple date, and log message.
    // Close the file.

    [demoBackgrounderUserInterface
     demoLogFormat:@"%@ %@", [DemoUtility simpleDate], message];
}

-(void)demoPickAndExecute:(int)pickListIndex
{
    ListItem *listItem = (ListItem *)[self.list objectAtIndex:pickListIndex];
    demoBackgrounderUserInterface = DEMOUI;
    if ([listItem hasPath]) {
        demoBackgrounderLogger(@"Setting logger.\n");
        [[Backgrounder sharedInstance] setLogger:demoBackgrounderLogger];
        [[Backgrounder sharedInstance] startPath:listItem.path];
    }
    else {
        if ([listItem.label isEqualToString:@"Stop"]) {
            [[Backgrounder sharedInstance] stop];
            self.telephony = nil;
        }
        else if ([listItem.label isEqualToString:@"Telephony"]) {
            self.telephony = [Telephony new];
            self.last_message = nil;
            [self.telephony start:^(NSString *message) {
                demoBackgrounderLogger(message);
            }];
        }
        else {
            if (DEMOUI) {
                [DEMOUI demoLogFormat:@"Unknown Backgrounder command \"%@\".\n",
                 listItem.label];
            }
        }
    }
    
    return;
}

@end
