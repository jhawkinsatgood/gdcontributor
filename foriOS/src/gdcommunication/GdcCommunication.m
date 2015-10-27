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

#import "GdcCommunication.h"

#import <GD/GDFileManager.h>

@interface GdcCommunication()
@property (nonatomic) NSMutableData *receivedData;
-(void)logFormat:(NSString *)format, ...;
@end

@implementation GdcCommunication

-(void)logFormat:(NSString *)format, ...
{
    va_list parameters;
    va_start(parameters, format);
    NSString *message = [[NSString alloc] initWithFormat:format
                                               arguments:parameters];
    va_end(parameters);
    
    self.logger(message);
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self logFormat:@"Connection failed with error - \"%@\" \"%@\"\n",
     [error localizedDescription],
     [[error userInfo]
      objectForKey:NSURLErrorFailingURLStringErrorKey]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *str =
    [[NSString alloc] initWithBytes:[self.receivedData bytes]
                             length:[self.receivedData length]
                           encoding:NSASCIIStringEncoding];
    [self logFormat:@"Connection finished loading. "
     "Received %lu bytes of data.\n\"%@\"\n",
     (unsigned long)[self.receivedData length], str];
    
}

- (void)       connection:(NSURLConnection *)connection
          didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    [self logFormat:@"Connection didSendBodyData:%ld of %ld. expected:%ld\n",
     (long)bytesWritten, (long)totalBytesWritten,
     (long)totalBytesExpectedToWrite];
}

+(NSString *)contentTypeFor:(NSString *)path
{
    NSString *extension = [[path pathExtension] lowercaseString];
    if ([extension isEqualToString:@"aiff"]) {
        return @"audio/aiff";
    }
    else if ([extension isEqualToString:@"jpeg"]) {
        return @"image/jpeg";
    }
    return @"application/octet-stream";
}

-(BOOL)upload:(NSString *)path to:(NSString *)url
{
    [self logFormat:@"gdCommunication upload \"%@\"\n", path];
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:url]];
    
    // Set up the request...
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:120.0];
    [request
     setValue:[GdcCommunication contentTypeFor:path]
     forHTTPHeaderField:@"Content-Type"];
    
    // ... Then get the content, i.e. HTTP body, from a file in the secure file
    // system.
    
    NSError *error = nil;
    NSData *fileData = [[GDFileManager defaultManager] contentsAtPath:path];
    if (fileData == nil) {
        [self logFormat:@"Error reading file \"%@\": %@.\n", path, error];
        return NO;
    }
    [request
     setValue:[NSString stringWithFormat:@"%lu",
               (unsigned long)[fileData length]]
     forHTTPHeaderField:@"Content-Length"];
    
    [self logFormat:@"Content length header %lu.\n",
     (unsigned long)[fileData length]];

    [request setHTTPBody:fileData];
    
    // Prepare to receive data
    self.receivedData = [NSMutableData data];
    
    // Create the connection with the request, and send with this class as the
    // delegate.
    NSURLConnection *nsURLConnection =
    [[NSURLConnection alloc] initWithRequest:request
                                    delegate:self
                            startImmediately:YES];
    
    if (nsURLConnection) {
        [self logFormat:@"URL loading system connection open OK."
         " URL \"%@\"\n", [request URL]];
        return YES;
    }
    else {
        [self logFormat:@"URL loading system connection failed to open."
         " URL \"%@\"\n", [request URL]];
        self.receivedData = nil;
        return NO;
    }
}

-(instancetype)init
{
    self = [super init];
    // Set a default logger.
    self.logger = GDC_COMMUNICATION_LOGGER(message) {
        NSLog(@"%@", message);
    };
    return self;
}

@end
