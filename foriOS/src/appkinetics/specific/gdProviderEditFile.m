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

#import "gdProviderEditFile.h"
#import "gdRequestEditFile.h"

@implementation gdProviderEditFile

static gdProviderListener specificListener = GDPROVIDERLISTENER(request){
    NSString *errDesc = nil;
    NSArray *attachments = [request getAttachments];
    if (!attachments) {
        errDesc = @"No attachments. Should have one.";
    }
    else if (attachments.count != 1) {
        errDesc = [NSString stringWithFormat:
                   @"Wrong number of attachments: %lu. Should have one.",
                   (unsigned long)attachments.count];
    }

    // Create and send a custom error object with code 1, which applies to
    // any invalid request.
    if (errDesc != nil) {
        [[[request
        setReplyParameter:[NSError
                           errorWithDomain:[request getServiceID]
                           code:1
                           userInfo:[NSDictionary
                                     dictionaryWithObject:errDesc
                                     forKey:NSLocalizedDescriptionKey]]]
          setReplyForegroundPreference:GDEPreferPeerInForeground]
        replyOrMessage:nil];
        // Block propagation.
        return nil;
    }

    // If the request is valid, send a null response as required by the
    // service definition.
    [[request setReplyForegroundPreference:GDEPreferMeInForeground]
    replyOrMessage:nil];
    
    // Create a specific request object for propagation
    return [[gdRequestEditFile new] storeFrom:request];
};

-(instancetype)init
{
    self = [super init];
    [[[[self setServiceID:@"com.good.gdservice.edit-file"]
      setServiceVersion:@"1.0.0.0"]
      addDefinedMethods:@[@"editFile"]]
      addListener:specificListener];
    return self;
}

@end
