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

#import "DemoUtility.h"
#import <GD/GDFileSystem.h>
#import <GD/GDAppServer.h>

@interface DemoUtility()
+(NSString *)basicContent;
@end

@implementation DemoUtility

+(NSString *)basicContent
{
    return [NSString stringWithFormat:@"%@%@.",
            @"Demonstration file created by ", NSStringFromClass([self class])];
}

+(NSString *)simpleDate
{
    return [NSDateFormatter localizedStringFromDate:[NSDate new]
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterLongStyle];
}

+(NSString *)createFileOrError:(NSString *)filename content:(NSString *)content
{
    NSString *message = nil;
    
    if (!content) {
        NSString *extension = [[filename pathExtension] lowercaseString];
        if ([extension isEqualToString:@"txt"]) {
            content = [NSString stringWithFormat:@"%@\n%@",
                       [self basicContent], [self simpleDate]];
        }
        else if ([extension isEqualToString:@"html"] ||
                 [extension isEqualToString:@"htm"]) {
            content = [NSString stringWithFormat:
                       @"<html><head></head><body>"
                       "<p>%@</p><p>%@</p></body></html>",
                        [self basicContent], [self simpleDate]];
        }
        else {
            message = [NSString stringWithFormat:
                       @"Could not deduce content from extension \"%@\"",
                       extension];
        }
    }
    
    if (content) {
        NSData *contentAsData = [content dataUsingEncoding:NSASCIIStringEncoding
                                      allowLossyConversion:YES];
        
        NSError *error;
        BOOL wroteOK = [GDFileSystem writeToFile:contentAsData
                                            name:filename
                                           error:&error];
        if (!wroteOK) {
            message = [NSString stringWithFormat:
                       @"Write failed for \"%@\". %@.", filename, error ];
        }
    }
    
    return message;
}

+(NSString *)copyFromResourceDirectoryOrError:(NSString *)directory
                                         name:(NSString **)filename
{
    NSString *message = nil;
    NSData *data = nil;
    
    NSArray *resource_list =
    [[NSBundle mainBundle] pathsForResourcesOfType:nil
                                       inDirectory:directory];
    
    if ( !resource_list ) {
        message = [NSString stringWithFormat:@"No resource directory \"%@\"",
                   directory];
    }
    else if ([resource_list count] < 1) {
        message = [NSString stringWithFormat:@"Empty resource directory \"%@\"",
                   directory];
    }
    else {
        NSURL *copyURL = [NSURL fileURLWithPath:resource_list[0]];
        data = [NSData dataWithContentsOfURL:copyURL];
        if (!data) {
            message =
            [NSString stringWithFormat:@"Failed to read data for URL \"%@\"",
             copyURL];
        }
        *filename = [copyURL lastPathComponent];
    }
    
    if (data) {
        NSError *error;
        BOOL wroteOK = [GDFileSystem writeToFile:data
                                            name:*filename
                                           error:&error];
        if (!wroteOK) {
            message = [NSString stringWithFormat:
                       @"Write failed for \"%@\". %@.", *filename, error ];
        }
    }
    
    return message;
}
                
+(NSString *)createFileOrError:(NSString *)filename
{
    return [self createFileOrError:filename content:nil];
}

+(NSString *)createFilesOrError:(NSArray *)filenames
{
    NSMutableString *ret = [NSMutableString new];
    BOOL allOK = YES;
    for (int i=0; i<filenames.count; i++) {
        NSString *error = [self createFileOrError:filenames[i]];
        if (error != nil) {
            [ret appendString:error];
            [ret appendString:@"\n"];
            allOK = NO;
        }
    }
    if (allOK) return nil;
    return ret;
}

+(NSString *)createDirectoryOrError:(NSString *)path
{
    NSError *error = nil;
    BOOL dirOK = [GDFileSystem createDirectoryAtPath:path
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error];
    if (dirOK) return nil;
    return [NSString stringWithFormat:
            @"Failed to create directory \"%@\". %@.\n", path, error];
}

+(NSString *)statFile:(NSString *)filepath
{
    NSError *err = nil;
    GDFileStat myStat;
    BOOL statOK = [GDFileSystem getFileStat:filepath to:&myStat error:&err];
    if (statOK) {
        NSDate *lastModified =
        [NSDate dateWithTimeIntervalSince1970:myStat.lastModifiedTime];
        
        return [NSString
                stringWithFormat:@"Length: %lld, last modified time: %@.\n",
                myStat.fileLen, [lastModified description]];
    }
    else {
        return [NSString stringWithFormat:@"Failed to stat file \"%@\". %@.\n",
                filepath, err];
    }
}

+(NSString *)byteDump:(NSString *)filepath
{
    NSError *err = nil;
    // Use the simple read-at-once API, rather than the stream-based API.
    NSData *readResult = [GDFileSystem readFromFile:filepath error:&err];
    if (readResult) {
        NSMutableString *ret = [NSMutableString new];
        char *reader = (char *)[readResult bytes];
        int bytes_read = 0;
        while ( bytes_read < 80 && bytes_read < readResult.length && reader) {
            if (*reader >= ' ' && *reader <= '~') {
                [ret appendFormat:@"%c", *reader];
            }
            else {
                [ret appendFormat:@"\\x%02X", * reader];
            }
            reader++;
            bytes_read++;
        }
        return [NSString stringWithFormat:@"Read %d bytes OK: \"%@\".\n",
                bytes_read, ret];
    }
    return [NSString stringWithFormat:@"Failed to read file \"%@\". %@.\n",
            filepath, err];
}

+(NSArray *)dictionariesFromGDAppServers:(NSArray *)appServers
{
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:appServers.count];
    for (int i=0; i<appServers.count; i++) {
        GDAppServer *appServeri = (GDAppServer *)(appServers[i]);
        NSDictionary *dictionary =
        [NSDictionary dictionaryWithObjectsAndKeys:
         appServeri.server, @"server",
         appServeri.port, @"port",
         appServeri.priority, @"priority", nil];
        ret[i] = dictionary;
    }
    return ret;
}

@end
