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

#import <Foundation/Foundation.h>

@import AudioToolbox;

typedef void (backgrounder_logger)(NSString *message);

typedef int (backgrounder_opener)
(void *inParameter, AudioStreamBasicDescription *asbd, AudioFileID *audioFileID,
void **audioFileClientData, backgrounder_logger logger);

typedef int (backgrounder_closer)
(void *inParameter, void *audioFileClientData, backgrounder_logger logger);

// Following might be able to replace backgrouner_logger, above, in due course.
typedef void (^BackgrounderLogger) (NSString *message);
#define BACKGROUNDER_LOGGER(MESSAGE) ^void (NSString *MESSAGE)

@interface Backgrounder : NSObject

+(instancetype)sharedInstance;

+(NSURL *)URLForRecording:(char *)inParameter;

// Cannot have properties with function type, so this has a setter.
-(void)setLogger:(backgrounder_logger)logger;

int logOSError(NSString *preamble,
               OSStatus osStatus,
               backgrounder_logger logger);

-(BOOL)startPlaybackPath:(NSString *)path;
-(BOOL)startRecordingPath:(NSString *)path;
-(BOOL)startPlaybackWithOpen:(backgrounder_opener *)open_func
                       close:(backgrounder_closer *)close_func
                   parameter:(void *)parameter;
-(BOOL)startRecordingWithOpen:(backgrounder_opener *)open_func
                        close:(backgrounder_closer *)close_func
                    parameter:(void *)parameter;

-(BOOL)stop;

@end
