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

#import "DemoTicker.h"
#import "gdRuntimeDispatcher.h"

@interface DemoTicker()
@property (weak, nonatomic) NSTimer *timer;
@property (assign, nonatomic) int dotCount;
@end

@implementation DemoTicker

@synthesize demoExecuteLabel;

-(instancetype)init
{
    self = [super init];
    demoExecuteLabel = @"Start or Stop Ticker";
    return self;
}

-(NSArray *)demoExecuteOrPickList
{
    if (self.timer == nil) {
        [DEMOUI demoLogString:@"Starting ticker "];
        self.dotCount = 0;
        self.timer =
        [NSTimer scheduledTimerWithTimeInterval:10.0
                                         target:self
                                       selector:@selector(printDot:)
                                       userInfo:nil
                                        repeats:YES];
        [self.timer fire];
    }
    else {
        [self.timer invalidate];
        self.timer = nil;
        [DEMOUI demoLogString:@" Ticker stopped.\n"];
    }

    
    [[gdRuntimeDispatcher sharedInstance]
     addObserverForEventType:GDAppEventNotAuthorized
     usingBlock:GDRUNTIMEOBSERVER(event) {
         if (event.code == GDErrorIdleLockout) {
             [DEMOUI demoLogString:@" Idle Lock "];
         }
     }];

    
    
    return nil;
}

-(void)printDot:(NSTimer *)timer
{
    [DEMOUI demoLogString:@"."];
    if (++self.dotCount % 10 == 0) {
        [DEMOUI demoLogString:@"\n"];
    }
}

@end
