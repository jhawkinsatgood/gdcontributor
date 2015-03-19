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

#import <GD/GDFileSystem.h>

#import "DemoProvideEditFile.h"
#import "DemoUtility.h"
#import "gdProviderEditFile.h"
#import "gdRequestEditFile.h"
#import "gdRequestSaveEditedFile.h"

@interface DemoProvideEditFile()
@property (nonatomic, strong) gdProviderEditFile *provider;
@property (nonatomic, strong) gdRequestEditFile *request;
@end

@implementation DemoProvideEditFile

@synthesize demoExecuteLabel;

id<DemoUserInterface> userInterface = nil;
DemoProvideEditFile *blockSelf = nil;

-(instancetype)init
{
    self = [super init];
    demoExecuteLabel = nil;
    return self;
}

-(void)demoLoad
{
    if (!DEMOUI) {
        assert("DemoProvideEditFile set up attempted without user "
               "interface. Call demoSetUserInterface before demoSetUp.");
    }

    userInterface = DEMOUI;
    blockSelf = self;
    self.provider = [gdProviderEditFile new];
    [self.provider addListener:demoListener];
    [userInterface demoLogFormat:@"Ready for: %@\n", [self.provider getServiceID]];
}

-(NSArray *)demoExecuteOrPickList
{
    return nil;
}

-(BOOL)demoSave:(NSString *)content
{
    [DEMOUI demoLogFormat:@"DemoProvideEditFile saving \"%@\"\n", content];
    
    // If savedData isn't null, write it to a temporary file, in the secure
    // store, so that it can be sent back to the original application.
    // TODO: The file should get deleted later, in the onMessageSent
    // callback.
    NSString *filename = nil;
    if (content != nil) {
        // Create a temporary file name from the name of this class, plus the
        // request ID, plus a suffix.
        // ToDo: Use a proper temporary filename generator.
        filename = [NSString stringWithFormat:@"/%@-%@%@%@",
                    NSStringFromClass([self class]),
                    @"request", [self.request getRequestID], @"tempfile"];
        NSString *error = [DemoUtility createFileOrError:filename
                                                 content:content];
        if (error) {
            [DEMOUI demoLogString:error];
            return NO;
        }
        [DEMOUI demoLogFormat:@"Created file \"%@\".\n", filename];
    }

    // Send the service request back to the application that sent the file
    // in the first place.
    // If filename is nil then the method will be releaseEdit.
    // Otherwise the method will be saveEdit and the file created above is
    // added as an attachment.
    gdRequestSaveEditedFile *requestSave = [gdRequestSaveEditedFile new];
    [requestSave setApplication:[self.request getApplication]];
    if (filename == nil) {
        [requestSave setMethodReleaseEdit];
    }
    else {
        [[requestSave setMethodSaveEdit] addAttachments:@[filename]];
    }
    [[requestSave setIdentificationData:[self.request getIdentificationData]]
     sendOrMessage:nil];
    // The above returns a message if there is an error in the send. The
    // message is also inserted into the Request object, which is dumped
    // below, so there is no need to log it additionally.
    [DEMOUI demoLogFormat:@"Sent request: %@\n", requestSave];
    return YES;
}

static gdProviderListener demoListener = GDPROVIDERLISTENER(request){
    [userInterface demoLogFormat:@"DemoProvideEditFile received %@", request];
    blockSelf.request = (gdRequestEditFile *)request;

    NSString *filename = [blockSelf.request getAttachment];
    
    // Read the file contents into a buffer
    NSError *readErr = nil;
    NSData *readResult = [GDFileSystem readFromFile:filename error:&readErr];
    NSString *read = nil;
    
    if (readResult) {
        read = [NSString stringWithUTF8String:[readResult bytes]];
        [userInterface demoLogFormat:@"Read file OK \"%@\"\n", read];
    }
    else {
        [userInterface demoLogFormat:@"Failed to read: \"%@\"\n", readErr];
    }
    
    if (read) {
        // Pass the data from the file to the supplied editor. Also pass a
        // reference to a block in this class that is to be executed when the
        // user saves or cancels out of the editor.
        [userInterface demoEdit:read savingTo:blockSelf];
    }

    return blockSelf.request;
};

@end
