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

#import "BackgrounderForGoodDynamics.h"

@import AudioToolbox;

#include <GD/GD_C_FileSystem.h>
#include <stdio.h>

typedef struct GD_AUDIO_FILE {
    char *path;
    GD_FILE *file;
    backgrounder_logger *logger;
} gd_audio_file;

// Define the following as X to switch on diagnostic logging.
#define DIAGNOSTIC(X) ;

@implementation BackgrounderForGoodDynamics

static OSStatus gdReadFunc(void *inClientData,
                           SInt64 inPosition,
                           UInt32 requestCount,
                           void *buffer,
                           UInt32 *actualCount )
{
    gd_audio_file *gdAudioFile = inClientData;
    DIAGNOSTIC(gdAudioFile->logger(@"gdReadFunc\n");)
    OSStatus osStatus = noErr;
    if (GD_fseek(gdAudioFile->file, inPosition, SEEK_SET) < 0) {
        int my_errno = errno;

        NSString *message =
        [NSString stringWithFormat:
         @"gdReadFunc GD_fseek(,%lld,%d) \"%s\" failed: %d %s.\n",
         inPosition, SEEK_SET, gdAudioFile->path,
         my_errno, strerror(my_errno) ];

        gdAudioFile->logger(message);
        osStatus = kAudioFilePositionError;
    }
    else {
        UInt32 count = (UInt32)GD_fread(buffer, 1, requestCount,
                                        gdAudioFile->file);
        if (count != requestCount) {
            if (GD_ferror(gdAudioFile->file)) {
                int my_errno = errno;
                NSString *message =
                [NSString stringWithFormat:
                 @"gdReadFunc GD_fread(,,%d,) \"%s\" failed: %d %s.\n",
                      (unsigned int)requestCount, gdAudioFile->path,
                      my_errno, strerror(my_errno)];
                gdAudioFile->logger(message);
                osStatus = kAudioFileUnspecifiedError;
            }
            if (GD_feof(gdAudioFile->file)) {
                // Could close the file and free some details here, maybe.
                osStatus = kAudioFileEndOfFileError;
            }
        }
        *actualCount = count;
    }
    
    return osStatus;
} /* gdReadFunc() */

static SInt64 gdGetSizeFunc(void *inClientData)
{
    gd_audio_file *gdAudioFile = inClientData;

    // Determine the size of the file by seeking to the end and then getting our
    // position. There is no need to save and restore the current position
    // because the read and write interfaces always specify an explicit
    // position.
    GD_fseeko(gdAudioFile->file, 0, SEEK_END);
    SInt64 size = GD_ftello(gdAudioFile->file);
    

    DIAGNOSTIC(gdAudioFile->logger([NSString
                                    stringWithFormat:@"gdGetSizeFunc %lld\n",
                                    size]);)
    return size;
} /* gdGetSizeFunc() */

static OSStatus gdWriteFunc(void *inClientData,
                           SInt64 inPosition,
                           UInt32 requestCount,
                           const void *buffer,
                           UInt32 *actualCount )
{
    gd_audio_file *gdAudioFile = inClientData;
    DIAGNOSTIC(gdAudioFile->logger(@"gdWriteFunc\n");)
    OSStatus osStatus = noErr;
    if (GD_fseek(gdAudioFile->file, inPosition, SEEK_SET) < 0) {
        int my_errno = errno;
        
        NSString *message =
        [NSString stringWithFormat:
         @"gdWriteFunc GD_fseek(,%lld,%d) \"%s\" failed: %d %s.\n",
         inPosition, SEEK_SET, gdAudioFile->path,
         my_errno, strerror(my_errno) ];
        
        gdAudioFile->logger(message);
        osStatus = kAudioFilePositionError;
    }
    else {
        UInt32 count = (UInt32)GD_fwrite(buffer, 1, requestCount,
                                         gdAudioFile->file);
        if (count != requestCount) {
            if (GD_ferror(gdAudioFile->file)) {
                int my_errno = errno;
                gdAudioFile->logger([NSString stringWithFormat:
                                     @"gdWriteFunc GD_fwrite(,,%d,) "
                                     "\"%s\" failed: %d %s.\n",
                                     (unsigned int)requestCount,
                                     gdAudioFile->path,
                                     my_errno, strerror(my_errno)] );
                osStatus = kAudioFileUnspecifiedError;
            }
            if (GD_feof(gdAudioFile->file)) {
                // Could close the file and free some details here, maybe.
                osStatus = kAudioFileEndOfFileError;
            }
        }
        *actualCount = count;
    }
    
    return osStatus;
} /* gdWriteFunc() */

static OSStatus gdSetSizeFunc(void *inClientData, SInt64 inSize)
{
    gd_audio_file *gdAudioFile = inClientData;
    DIAGNOSTIC(gdAudioFile->logger([NSString
                                    stringWithFormat:@"gdSetSizeFunc(%lld)\n",
                                    inSize]);)
    
    // Use our own callback to get the current size.
    SInt64 size = gdGetSizeFunc(gdAudioFile);

    // The GD_ftruncate function actually either extends or truncates, depending
    // on the relative sizes specified.
    if (inSize != size) {
        if ( GD_ftruncate(gdAudioFile->file, (off_t)inSize) != 0 ){
            return kAudioFileUnspecifiedError;
        }
    }
    
    // There is no need to save and restore the current file position, because
    // the read and write interfaces always specify an explicit file position.
    
    return noErr;
} /* gdSetSizeFunc() */

static int BackgrounderForGoodDynamics_open(void *inParameter,
                                            AudioStreamBasicDescription *asbd,
                                            AudioFileID *audioFileID,
                                            void **audioFileClientData,
                                            backgrounder_logger logger)
{
    char *path = inParameter;
    gd_audio_file *gdAudioFile = malloc(sizeof(gd_audio_file));
    
    if (!gdAudioFile) {
        return NO;
    }

    gdAudioFile->path = path;
    gdAudioFile->logger = logger;

    OSStatus osStatus = noErr;
    NSString *message = nil;
    if (asbd) {
        // Stream description provided, we are creating a file.
        char *mode = "w+";
        if (!( gdAudioFile->file = GD_fopen(gdAudioFile->path, mode) )) {
            // Set an error code so that further processing is skipped.
            osStatus = kAudioFileFileNotFoundError;
            message = [NSString stringWithFormat:@"GD_fopen(\"%s\", \"%s\")",
                       gdAudioFile->path, mode];
        }
        
        if (osStatus == noErr) {
            osStatus = AudioFileInitializeWithCallbacks(gdAudioFile,
                                                        gdReadFunc,
                                                        gdWriteFunc,
                                                        gdGetSizeFunc,
                                                        gdSetSizeFunc,
                                                        kAudioFileAIFFType,
                                                        asbd,
                                                        0,
                                                        audioFileID);
            message = @"AudioFileInitializeWithCallbacks";
        }
    }
    else {
        // No stream description, we are reading a file.
    
        char *mode = "r";
        if (!( gdAudioFile->file = GD_fopen(gdAudioFile->path, mode) )) {
            // Set an error code so that further processing is skipped.
            osStatus = kAudioFileFileNotFoundError;
            message = [NSString stringWithFormat:@"GD_fopen(\"%s\", \"%s\")",
                       gdAudioFile->path, mode];
        }

        if (osStatus == noErr) {
            //
            // The writing and setting parameters must be NULL to avoid an
            // automatic permissions error in case the format cannot be
            // written by the device. See:
            // https://developer.apple.com/library/ios/qa/qa1676/_index.html
            //
            osStatus = AudioFileOpenWithCallbacks(gdAudioFile,
                                                  gdReadFunc,
                                                  NULL,
                                                  gdGetSizeFunc,
                                                  NULL,
                                                  0,
                                                  audioFileID);
            message = @"AudioFileOpenWithCallbacks";
        }
    }

    // Slightly naughty use of function in Backgrounder in next line.
    if (logOSError(message, osStatus, logger)) {
        // Some error occurred. It's already been logged, here we do the
        // clean-up: Close the file handle, if it was opened, and free any
        // allocation.
        if (gdAudioFile->file) GD_fclose(gdAudioFile->file);
        free(gdAudioFile);
        return FALSE;
    }

    *audioFileClientData = gdAudioFile;
    return TRUE;
}

static int BackgrounderForGoodDynamics_close(void *inParameter,
                                             void *audioFileClientData,
                                             backgrounder_logger logger)
{
    gd_audio_file *gdAudioFile = audioFileClientData;
    int ret = (GD_fclose(gdAudioFile->file) == 0);

    struct stat stat;
    SInt64 size = -1;
    
    if (GD_stat(gdAudioFile->path, &stat) == 0) {
        size = stat.st_size;
    }
    logger([NSString stringWithFormat:
            @"BackgrounderForGoodDynamics_close \"%s\" %lld\n",
            gdAudioFile->path, size]);
    
    if (ret) free(audioFileClientData);
    return ret;
}

+(BOOL)gdStartRecording:(NSString *)path in:(Backgrounder *)backgrounder
{
    return [backgrounder
            startRecordingWithOpen:BackgrounderForGoodDynamics_open
            close:BackgrounderForGoodDynamics_close
            parameter:strdup([path
                              cStringUsingEncoding:NSASCIIStringEncoding])];
}

+(BOOL)gdStartPlayback:(NSString *)path in:(Backgrounder *)backgrounder
{
    return [backgrounder
            startPlaybackWithOpen:BackgrounderForGoodDynamics_open
            close:BackgrounderForGoodDynamics_close
            parameter:strdup([path
                              cStringUsingEncoding:NSASCIIStringEncoding])];
}

@end
