/* Copyright (c) 2016 Good Technology Corporation
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
#import <GD/GDFileManager.h>

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
    // [NSDate new] gives the time now.
    return [self simpleDate:[NSDate new]];
}

+(NSString *)simpleDate:(NSDate *)nsDate
{
    return [NSDateFormatter localizedStringFromDate:nsDate
                                          dateStyle:NSDateFormatterMediumStyle
                                          timeStyle:NSDateFormatterLongStyle];
}

+(NSString *)documentsDirectory
{
    NSArray *candidates =
    NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                        NSUserDomainMask,
                                        YES);
    
    if (candidates.count >= 1) {
        return candidates[0];
    }
    
    return nil;
}

+(NSString *)pathForStub:(NSString *)stub
{
    return [self pathForStub:stub extension:nil];
}

+(NSString *)pathForStub:(NSString *)stub extension:(NSString *)extension
{
    if (extension) {
        stub = [stub stringByAppendingPathExtension:extension];
    }
    NSMutableArray *pathComponents = [NSMutableArray arrayWithObject:stub];
    
    // Next line will crash if there isn't a valid documents directory.
    [pathComponents insertObject:[self documentsDirectory] atIndex:0];

    return [NSString pathWithComponents:pathComponents];
}

+(NSString *)createFileOrError:(NSString *)path content:(NSString *)content
{
    NSString *message = nil;
    
    if (!content) {
        NSString *extension = [[path pathExtension] lowercaseString];
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
        
        BOOL wroteOK =
        [[GDFileManager defaultManager] createFileAtPath:path
                                                contents:contentAsData
                                              attributes:nil];
        if (!wroteOK) {
            message = [NSString stringWithFormat:
                       @"Create failed for \"%@\".", path];
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
        *filename = [self pathForStub:[copyURL lastPathComponent]];
    }
    
    if (data) {
        BOOL wroteOK = [[GDFileManager defaultManager]
                        createFileAtPath:*filename
                        contents:data
                        attributes:nil];
        if (!wroteOK) {
            message = [NSString stringWithFormat:
                       @"Create failed for \"%@\".", *filename];
        }
    }
    
    return message;
}
                
+(NSString *)createFileOrError:(NSString *)path
{
    return [self createFileOrError:path content:nil];
}

+(NSString *)createFilesOrError:(NSArray *)paths
{
    NSMutableString *ret = [NSMutableString new];
    BOOL allOK = YES;
    for (int i=0; i<paths.count; i++) {
        NSString *error = [self createFileOrError:paths[i]];
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
    BOOL dirOK = [[GDFileManager defaultManager] createDirectoryAtPath:path
                                           withIntermediateDirectories:YES
                                                            attributes:nil
                                                                 error:&error];
    if (dirOK) return nil;
    return [NSString stringWithFormat:
            @"Failed to create directory \"%@\". %@.\n", path, error];
}

+(NSString *)statFile:(NSString *)filepath
{
    NSError *error = nil;
    NSDictionary *attributes =
    [[GDFileManager defaultManager] attributesOfItemAtPath:filepath
                                                     error:&error];

    if (attributes == nil) {
        return [NSString stringWithFormat:@"Failed to stat file \"%@\". %@.\n",
                filepath, error];
    }

    NSDate *lastModifiedDate = [attributes fileModificationDate];
    if (!lastModifiedDate) {
        lastModifiedDate = [attributes fileCreationDate];
    }

    NSString *lastModified = nil;
    if (lastModifiedDate) {
        lastModified = [self simpleDate:lastModifiedDate];
    }
    
    return [NSString
            stringWithFormat:@"Length: %lld, Modified: %@.\n",
            [attributes fileSize], lastModified];
}

+(NSString *)byteDump:(NSString *)filepath
{
    NSError *err = nil;
    // Use the simple read-at-once API, rather than the stream-based API.
    NSData *readResult = [[GDFileManager defaultManager]
                          contentsAtPath:filepath];
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

+(NSString *)numberedFileIn:(NSString *)directory
                       stub:(NSString *)stub
                  extension:(NSString *)extension
{
    for (int suffix=1; suffix < 1000; suffix++) {
        // Set path to a candidate value.
        NSString *path =
        [[NSString pathWithComponents:
          @[ directory, [stub stringByAppendingFormat:@"%04d", suffix] ]
          ] stringByAppendingPathExtension:extension];
        
        BOOL isDirectory = NO;
        if (![[GDFileManager defaultManager] fileExistsAtPath:path
                                                  isDirectory:&isDirectory]) {
            // Path doesn't exist, we have a winner.
            return path;
        }

        // Path exists already, go around again.
    }
    return nil;
}

@end
