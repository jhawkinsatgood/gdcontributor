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

@implementation BackgrounderForGoodDynamics

static OSStatus gdReadFunc(void *inClientData,
                           SInt64 inPosition,
                           UInt32 requestCount,
                           void *buffer,
                           UInt32 *actualCount )
{
    gd_audio_file *gdAudioFile = inClientData;
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
        //        void *myBuffer = buffer;
        UInt32 readCount = (UInt32)GD_fread(buffer, 1, requestCount, gdAudioFile->file);
        if (readCount != requestCount) {
            if (GD_ferror(gdAudioFile->file)) {
                int my_errno = errno;
                NSString *message =
                [NSString stringWithFormat:
                 @"gdWriteFunc GD_fread(,,%d,) \"%s\" failed: %d %s.\n",
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
        *actualCount = readCount;
    }
    
    return osStatus;
}

static SInt64 gdGetSizeFunc(void *inClientData)
{
    gd_audio_file *gdAudioFile = inClientData;
    struct stat stat;
    SInt64 size = -1;
    
    if (GD_stat(gdAudioFile->path, &stat) == 0) {
        size = stat.st_size;
    }

    return size;
}

static int BackgrounderForGoodDynamics_open(void *inParameter,
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
    if (!( gdAudioFile->file = GD_fopen(gdAudioFile->path, "r") )) {
        free(gdAudioFile);
        // ToDo: Logging goes here.
        return NO;
    }

    //
    // The writing and setting parameters must be NULL to avoid an automatic
    // permissions error. See:
    // https://developer.apple.com/library/ios/qa/qa1676/_index.html
    //
    OSStatus osStatus = AudioFileOpenWithCallbacks(gdAudioFile,
                                                   gdReadFunc,
                                                   NULL,
                                                   gdGetSizeFunc,
                                                   NULL,
                                                   0,
                                                   audioFileID);

    if (logOSError(@"AudioFileOpenWithCallbacks", osStatus, logger)) {
        GD_fclose(gdAudioFile->file);
        free(gdAudioFile);
        return FALSE;
    }

    *audioFileClientData = gdAudioFile;
    return TRUE;
}

static int BackgrounderForGoodDynamics_close(void *inParameter,
                                             void *audioFileClientData)
{
    gd_audio_file *gdAudioFile = audioFileClientData;
    int ret = (GD_fclose(gdAudioFile->file) == 0);

    if (ret) free(audioFileClientData);

    return ret;
}

+(BOOL)gdStartPath:(NSString *)path logger:(backgrounder_logger)logger
{
    [[Backgrounder sharedInstance] setLogger:logger];
    return [[Backgrounder sharedInstance]
            startWithOpen:BackgrounderForGoodDynamics_open
            close:BackgrounderForGoodDynamics_close
            parameter:strdup([path
                              cStringUsingEncoding:NSASCIIStringEncoding])];
}

@end
