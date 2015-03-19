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

#import "DemoConsumeTransferFile.h"
#import "gdRequestTransferFile.h"

#import "DemoUtility.h"

@interface DemoConsumeTransferFile()
@property (strong, nonatomic)gdRequestTransferFile *request;
@end

@implementation DemoConsumeTransferFile

@synthesize demoExecuteLabel;

-(instancetype)init
{
    self = [super init];
    demoExecuteLabel = @"Transfer File";
    return self;
}

-(NSArray *)demoExecuteOrPickList {
    if (!_request) _request = [gdRequestTransferFile new];
    return [[_request queryProviders] getProviderNames];
}

-(void)demoPickAndExecute:(int)pickListIndex
{
    if (!_request) _request = [gdRequestTransferFile new];

    // Generate a file for illustration purposes.
    NSString *filename = [NSStringFromClass([self class])
                          stringByAppendingPathExtension:@"txt"];
    NSString *error = [DemoUtility createFileOrError:filename];
    if (error) {
        if (DEMOUI) [DEMOUI demoLogString:error];
        return;
    }

    // Send the request.
    error = [[[_request selectProvider:pickListIndex]
              addAttachments:@[filename]]
             sendOrMessage:nil];

    // Display the error, if any
    if (error && DEMOUI) [DEMOUI demoLogString:error];
    
    // Discard the request.
    _request = nil;
    return;
}

@end
