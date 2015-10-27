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

/* With thanks to the Audio Queue Services Programming Guide
 https://developer.apple.com/library/ios/documentation/MusicAudio/Conceptual/AudioQueueProgrammingGuide/AQRecord/RecordingAudio.html#//apple_ref/doc/uid/TP40005343-CH4-SW1
 */

#import "Backgrounder.h"

@import AVFoundation;

typedef enum {
    backgrounder_queue_state_STOPPED=0,
    backgrounder_queue_state_STARTED,
    backgrounder_queue_state_STOPPING
} backgrounder_queue_state;

// Define a C struct to hold the state. The audio APIs are C APIs, not
// Objective-C.

const int kInputBufferCount = 3;
typedef struct BACKGROUNDER_STATE {
    backgrounder_opener *open_func;
    backgrounder_closer *close_func;
    void *parameter;
    
    void *audioFileClientData;
    
    AudioQueueRef audioQueueRef;
    AudioFileID audioFileID;
    UInt32 byteCount;
    UInt32 packetCount;
    
    backgrounder_queue_state queue_state;
    backgrounder_logger *logger;
    
    uint playCount;
    
    AudioQueueBufferRef inputBuffers[kInputBufferCount];
    UInt32 bufferByteSize;
    SInt64 currentPacket;
    AudioStreamBasicDescription audioStreamBasicDescription;
    
} backgrounder_state;

@interface Backgrounder()
-(instancetype)init;

@property (assign, nonatomic) backgrounder_state *state;

-(BOOL)setUpAVAudioSession:(BOOL)active;
-(BOOL)resetState;
-(BOOL)startPlayback;
-(BOOL)startRecording;
@end

@implementation Backgrounder

/* logOSError - Logs an error message, if a specified OSStatus value represents
 * an error condition.
 * Returns TRUE if the OSStatus value represented an error.
 */
int logOSError(NSString *preamble,
               OSStatus osStatus,
               backgrounder_logger logger)
{
    if (osStatus == noErr) return FALSE;
    
    char *osStatusChars = (char *)&osStatus;
    char osStatusArray[sizeof(OSStatus) + 1];
    int i=0;
    for (; i<sizeof(OSStatus); i++) {
        osStatusArray[sizeof(OSStatus) - (i+1)] = *(osStatusChars + i);
    }
    osStatusArray[sizeof(OSStatus)] = 0;
    logger([NSString stringWithFormat:@"%@ failed %d \"%s\". Reminder: macerror\n",
            preamble, (int)osStatus, osStatusArray]);
    
    return TRUE;
}

/*
 * Conforms to AudioQueueInputCallback, which is declared in the 
 * Audio Toolbox/AudioQueue.h file.
 */
void audioQueueInputCallback(void *inUserData,
                             AudioQueueRef                   inAQ,
                             AudioQueueBufferRef             inBuffer,
                             const AudioTimeStamp *          inStartTime,
                             UInt32                          inNumberPacketDescriptions,
                             const AudioStreamPacketDescription *inPacketDescs
                             )
{
    backgrounder_state *state = (backgrounder_state *)inUserData;
    AudioStreamBasicDescription *asbd = &(state->audioStreamBasicDescription);
    
    if (inNumberPacketDescriptions == 0 &&
        asbd->mBytesPerPacket != 0)
    {
        inNumberPacketDescriptions =
        inBuffer->mAudioDataByteSize / asbd->mBytesPerPacket;
    }
    
    OSStatus osStatus = AudioFileWritePackets(state->audioFileID,
                                              false,
                                              inBuffer->mAudioDataByteSize,
                                              inPacketDescs,
                                              state->currentPacket,
                                              &inNumberPacketDescriptions,
                                              inBuffer->mAudioData );
    if (logOSError(@"AudioFileWritePackets", osStatus, state->logger)) {
        return;
    }

    state->currentPacket += inNumberPacketDescriptions;

    if (state->queue_state == backgrounder_queue_state_STOPPING) {
        return;
    }

    state->playCount++;
    state->logger([NSString
                   stringWithFormat:@"Play Count: %u\n", state->playCount]);

    osStatus = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    logOSError(@"AudioQueueEnqueueBuffer for input", osStatus, state->logger);
}

void DeriveBufferSize (AudioQueueRef audioQueue,
                       AudioStreamBasicDescription *asbd,
                       Float64 seconds,
                       UInt32 *outBufferSize
                       )
{
    static const int maxBufferSize = 0x50000;
    int maxPacketSize = asbd->mBytesPerPacket;
    
    if (maxPacketSize == 0) {
        UInt32 maxVBRPacketSize = sizeof(maxPacketSize);
        AudioQueueGetProperty(audioQueue,
                              kAudioQueueProperty_MaximumOutputPacketSize,
                              &maxPacketSize,
                              &maxVBRPacketSize );
    }

    Float64 numBytesForTime = asbd->mSampleRate * maxPacketSize * seconds;
    
    *outBufferSize =(UInt32) (numBytesForTime < maxBufferSize ?
                              numBytesForTime :
                              maxBufferSize);
}

OSStatus SetMagicCookieForFile (AudioQueueRef inQueue,
                                AudioFileID inFile,
                                backgrounder_logger *logger
                                )
{
    UInt32 cookieSize;
    OSStatus osStatus =
    AudioQueueGetPropertySize(inQueue,
                              kAudioQueueProperty_MagicCookie,
                              &cookieSize);

    if (!logOSError(@"Get magic cookie size", osStatus, logger)) {
        char* magicCookie = (char *) malloc(cookieSize);
        osStatus = AudioQueueGetProperty(inQueue,
                                         kAudioQueueProperty_MagicCookie,
                                         magicCookie,
                                         &cookieSize);
        if (!logOSError(@"Get magic cookie itself", osStatus, logger)) {
            osStatus = AudioFileSetProperty(inFile,
                                            kAudioFilePropertyMagicCookieData,
                                            cookieSize,
                                            magicCookie);
            logOSError(@"Set magic cookie", osStatus, logger);
        }
        free (magicCookie);
    }
    
    return osStatus;
}


void audioQueueOutputCallback(void *inUserData,
                              AudioQueueRef inAQ,
                              AudioQueueBufferRef inBuffer
                              )
{
    backgrounder_state *state = (backgrounder_state *)inUserData;
    if (state->queue_state == backgrounder_queue_state_STOPPING) {
        return;
    }
    
    UInt32 bytesRead = state->byteCount;
    UInt32 packetsRead = state->packetCount;
    OSStatus osStatus =
    AudioFileReadPacketData(state->audioFileID, TRUE,
                            &bytesRead,
                            inBuffer->mPacketDescriptions, 0,
                            &packetsRead,
                            inBuffer->mAudioData);
    logOSError(@"AudioFileReadPacketData", osStatus, state->logger);

    inBuffer->mAudioDataByteSize = bytesRead;
    inBuffer->mPacketDescriptionCount = packetsRead;

    if (state->queue_state == backgrounder_queue_state_STOPPING) {
        return;
    }
    
    osStatus = AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    logOSError(@"AudioQueueEnqueueBuffer for output", osStatus, state->logger);

    // I couldn't see a way to rewind an audio file. The above will read the
    // whole file and leave it at EOF. So, it seems necessary to close the file
    // here, both AudioFile and external if any.
    AudioFileClose(state->audioFileID);
    if (state->close_func) {
        if (state->close_func(state->parameter,
                              state->audioFileClientData,
                              state->logger))
        {
            state->audioFileClientData = NULL;
        };
    }

// Reopen the file.
    if (!state->open_func(state->parameter,
                          NULL,
                          &(state->audioFileID),
                          &(state->audioFileClientData),
                          state->logger)
        ) {
        return;
    }
    
    UInt32 framesPrepared;
    osStatus = AudioQueuePrime(inAQ, 0, &framesPrepared);
    logOSError(@"AudioQueuePrime", osStatus, state->logger);

    osStatus = AudioQueueStart(inAQ, NULL);
    logOSError(@"AudioQueueStart", osStatus, state->logger);
    
    state->playCount++;
    state->logger([NSString
                   stringWithFormat:@"Play Count: %u\n", state->playCount]);

    state->queue_state = backgrounder_queue_state_STARTED;
    return;
}

static void *getAudioProperty_malloc(AudioFileID audioFileID,
                                     AudioFilePropertyID property,
                                     backgrounder_logger logger)
{
    UInt32 outDataSize = 0;
    UInt32 isWritable = 0;
    OSStatus osStatus =
    AudioFileGetPropertyInfo(audioFileID, property, &outDataSize, &isWritable );
    if ( logOSError(@"getAudioProperty_malloc AudioFileGetPropertyInfo(,,,)",
                    osStatus, logger) ) {
        return NULL;
    }
    
    void *property_value = malloc(outDataSize);
    if (!property_value) {
        logger([NSString stringWithFormat:
                @"getAudioProperty_malloc failed malloc(%d).\n",
                (unsigned int)outDataSize]);
        return NULL;
    }
    memset(property_value, 0, outDataSize);
    
    // Uncomment the following to trigger an error.
    // outDataSize++;
    osStatus = AudioFileGetProperty(audioFileID, property,
                                    &outDataSize, property_value );
    if ( logOSError([NSString
                     stringWithFormat:
                     @"getAudioProperty_malloc AudioFileGetProperty(,,%d,) ",
                     (unsigned int)outDataSize],
                    osStatus, logger) ) {
        free(property_value);
        return NULL;
    }
    
    return property_value;
} // getAudioProperty_malloc()

/* getASBDmalloc - malloc an AudioStreamBasicDescription and populate if from
 * an AudioFileID.
 *
 * The documentation for AudioFileID properties is here:
 * https://developer.apple.com/library/ios/documentation/MusicAudio/Reference/AudioFileConvertRef/index.html#//apple_ref/doc/constant_group/Audio_File_Properties
 * It describes the property used in the appended as:
 * "An audio stream basic description containing the format of the audio data."
 */
AudioStreamBasicDescription *getASBD_malloc(AudioFileID audioFileID,
                                            backgrounder_logger logger)
{
    return getAudioProperty_malloc(audioFileID,
                                   kAudioFilePropertyDataFormat,
                                   logger);
}

UInt32 getAudioProperty_UInt32(AudioFileID audioFileID,
                               AudioFilePropertyID property,
                               backgrounder_logger logger)
{
    UInt32 *property_buffer = getAudioProperty_malloc(audioFileID,
                                                      property,
                                                      logger);
    if (!property_buffer) {
        return 0;
    }
    UInt32 ret = *property_buffer;
    free(property_buffer);
    return ret;
}

-(BOOL)setUpAVAudioSession:(BOOL)active
{
    NSError *error = nil;
    BOOL categoryOK = [[AVAudioSession sharedInstance]
                       setCategory:AVAudioSessionCategoryPlayAndRecord
                       withOptions:AVAudioSessionCategoryOptionMixWithOthers
                       error:&error];
    if (!categoryOK) {
        self.state->logger([NSString stringWithFormat:
                            @"Failed to set audio session category: %@.\n",
                            error]);
    }
    BOOL activeOK = [[AVAudioSession sharedInstance] setActive:active
                                                         error:&error];
    if (!activeOK) {
        self.state->logger([NSString stringWithFormat:
                            @"Failed to set audio session active %@: %@.\n",
                            active ? @YES : @NO, error]);
    }
    return categoryOK && activeOK;
}

-(BOOL)hasBackgroundModeAudio
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // ToDo: Replace the strings in the following with constants, if there are
    // any.
    BOOL hasIt = NO;
    NSString *audioMode = @"audio";
    NSArray *uiBackgroundModes = [infoDictionary
                                  objectForKey:@"UIBackgroundModes"];
    if (uiBackgroundModes) {
        for (NSString *mode in uiBackgroundModes) {
            if ([mode isEqualToString:audioMode]) {
                hasIt = YES;
                break;
            }
        }
    }
    if ( (!hasIt) && self.state && self.state->logger) {
        self.state->logger([NSString
                            stringWithFormat:
                            @"%s: Background mode \"%@\" not found.\n",
                            __PRETTY_FUNCTION__, audioMode]);
    }
    return hasIt;
}

-(BOOL)stop
{
    backgrounder_state *state = self.state;
    if (state && state->queue_state != backgrounder_queue_state_STOPPED ) {
        state->queue_state = backgrounder_queue_state_STOPPING;
        OSStatus osStatus = AudioQueueStop(state->audioQueueRef, true);
        if (logOSError(@"AudioQueueStop failed",
                       osStatus,
                       state->logger) )
        {
            return NO;
        }
        osStatus = AudioQueueDispose(state->audioQueueRef, true);
        if (logOSError(@"AudioQueueDispose failed",
                       osStatus,
                       state->logger) )
        {
            return NO;
        }

        
        AudioFileClose(state->audioFileID);
        if (state->close_func) {
            if (state->close_func(state->parameter,
                                  state->audioFileClientData,
                                  state->logger) )
            {
                state->audioFileClientData = NULL;
            };
        }

        
        state->queue_state = backgrounder_queue_state_STOPPED;
        if (state->parameter) {
            free(state->parameter);
            state->parameter = NULL;
        }
        [self setUpAVAudioSession:NO];
    }

    return YES;
}

-(BOOL)resetState
{
    if (![self stop]) {
        return NO;
    }
    backgrounder_logger *oldLogger = backgrounderLoggerDefault;
    if (self.state) {
        oldLogger = self.state->logger;
        free(self.state);
        self.state = NULL;
    }
    self.state = malloc(sizeof(backgrounder_state));
    if (!self.state) {
        if (oldLogger) {
            oldLogger([NSString stringWithFormat:
                       @"%s failed malloc(%lu) for backgrounder_state.\n",
                       __PRETTY_FUNCTION__, sizeof(backgrounder_state)]);
        }
        else {
            NSLog(@"%s failed malloc(%lu) for backgrounder_state.\n",
                  __PRETTY_FUNCTION__, sizeof(backgrounder_state));
        }
        return NO;
    }
    self.state->logger = oldLogger;
    self.state->playCount = 0;
    self.state->queue_state = backgrounder_queue_state_STOPPED;
    self.state->currentPacket = 0;

    return YES;
}

+(NSURL *)URLForRecording:(char *)inParameter
{
    NSString *path = [NSString stringWithCString:inParameter
                                        encoding:NSASCIIStringEncoding];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *array = [fileManager URLsForDirectory:NSDocumentDirectory
                                         inDomains:NSUserDomainMask];
    NSURL *directory = (NSURL *)array[0];
    return [directory URLByAppendingPathComponent:path];
}

static int openBackgrounderPath(void *inParameter,
                                AudioStreamBasicDescription *asbd,
                                AudioFileID *audioFileID,
                                void **audioFileClientData,
                                backgrounder_logger logger)
{
    NSURL *audioURL;
    if (asbd) {
        audioURL = [Backgrounder URLForRecording:inParameter];
    }
    else {
        // It seems pretty nuts to create an NSURL that is going to be bridged to
        // a CFURLRef. However, I couldn't seem to create a CFStringRef from the
        // C string that is in the ->path. The CFStringCreateWithCStringNoCopy and
        // CFStringCreateWithCString functions always returned NULL. Without a
        // CFStringRef it didn't seem possible to create a CFURLRef. The bridge
        // works.
        audioURL = [NSURL fileURLWithPath:
                    [NSString stringWithCString:inParameter
                                       encoding:NSASCIIStringEncoding]];
    }
    const char *reason = (asbd ? "writing" : "resource");
    if (!audioURL) {
        logger([NSString stringWithFormat:@"No URL for %s \"%s\"\n",
                reason, inParameter]);
        return FALSE;
    }
    
    int *wasCreated = malloc(sizeof(int));
    *audioFileClientData = wasCreated;
    
    int ret = TRUE;
    if (asbd) {
        OSStatus osStatus = AudioFileCreateWithURL((__bridge CFURLRef)(audioURL),
                                          kAudioFileAIFFType, asbd,
                                          kAudioFileFlags_EraseFile,
                                          audioFileID);
        ret = !logOSError([NSString stringWithFormat:
                           @"openBackgrounderPath AudioFileCreateWithURL "
                          "\"%@\" from path \"%s\"",
                           audioURL, (char *)inParameter],
                          osStatus, logger);
        *wasCreated = ret;
    }
    else {
        OSStatus osStatus = AudioFileOpenURL((__bridge CFURLRef)(audioURL),
                                             kAudioFileReadPermission,
                                             0,
                                             audioFileID );
        ret = !logOSError([NSString stringWithFormat:
                           @"openBackgrounderPath AudioFileOpenURL(%@,,,) "
                           "failed.\n", audioURL],
                          osStatus, logger);
        *wasCreated = FALSE;
    }
    
    return ret;
}

static int closeBackgrounderPath(void *inParameter,
                                 void *audioFileClientData,
                                 backgrounder_logger logger)
{
    int wasCreated = * (int *)audioFileClientData;
    if (wasCreated) {
        NSURL *audioURL = [Backgrounder URLForRecording:inParameter];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        NSDictionary *attributes =
        [fileManager attributesOfItemAtPath:[audioURL path] error:&error];
        if (attributes == nil) {
            logger([NSString
                    stringWithFormat:@"closeBackgrounderPath \"%s\" error %@\n"
                    "\"%@\"\n\"%@\"\n",
                    inParameter, error, audioURL, [audioURL path]]);
        }
        else {
            logger([NSString
                    stringWithFormat:@"closeBackgrounderPath \"%s\" %@\n",
                    inParameter, attributes]);
        }
    }

    free(audioFileClientData);

    return TRUE;
}


-(BOOL)startRecordingPath:(NSString *)path
{
    if (![self resetState]) return NO;

    self.state->open_func = openBackgrounderPath;
    self.state->close_func = closeBackgrounderPath;
    self.state->parameter =
    strdup([path cStringUsingEncoding:NSASCIIStringEncoding]);
    
    return [self startRecording];
}

-(BOOL)startPlaybackPath:(NSString *)path
{
    if (![self resetState]) return NO;
    
    self.state->open_func = openBackgrounderPath;
    self.state->close_func = closeBackgrounderPath;
    self.state->parameter =
    strdup([path cStringUsingEncoding:NSASCIIStringEncoding]);
    
    return [self startPlayback];
}

-(BOOL)startRecordingWithOpen:(backgrounder_opener *)open_func
                        close:(backgrounder_closer *)close_func
                    parameter:(void *)open_parameter
{
    if (![self resetState]) return NO;
    
    self.state->open_func = open_func;
    self.state->close_func = close_func;
    self.state->parameter = open_parameter;
    
    return [self startRecording];
}

-(BOOL)startPlaybackWithOpen:(backgrounder_opener *)open_func
                       close:(backgrounder_closer *)close_func
                   parameter:(void *)open_parameter
{
    if (![self resetState]) return NO;
    
    self.state->open_func = open_func;
    self.state->close_func = close_func;
    self.state->parameter = open_parameter;
    
    return [self startPlayback];
}

-(BOOL)startRecording
{
    backgrounder_state *state = self.state;
    
    // Following writes a warning to the log, if necessary.
    [self hasBackgroundModeAudio];

    AudioStreamBasicDescription *asbd = &(state->audioStreamBasicDescription);
    if (!asbd) {
        state->logger([NSString stringWithFormat:
                @"startRecording failed malloc(%lu).\n",
                sizeof(AudioStreamBasicDescription)]);
        return NO;
    }

    asbd->mFormatID = kAudioFormatLinearPCM;
    asbd->mSampleRate = 44100.0;
    asbd->mChannelsPerFrame = 2;
    asbd->mBitsPerChannel = 16;

    asbd->mBytesPerPacket = asbd->mBytesPerFrame =
    asbd->mChannelsPerFrame * sizeof(SInt16);

    asbd->mFramesPerPacket = 1;

    asbd->mReserved = 0;

    asbd->mFormatFlags =
    kLinearPCMFormatFlagIsBigEndian | kLinearPCMFormatFlagIsSignedInteger |
    kLinearPCMFormatFlagIsPacked;
    
    // In the following call, state is passed as the inUserData.
    // This makes the backgrounder_state accessible in the queue callback.
    OSStatus osStatus = AudioQueueNewInput(asbd,
                                           audioQueueInputCallback,
                                           state,
                                           NULL, kCFRunLoopCommonModes, 0,
                                           &(state->audioQueueRef) );
    if (logOSError(@"startRecording AudioQueueNewInput(...) failed.",
                   osStatus, state->logger)) {
        return NO;
    }
    
    UInt32 dataFormatSize = sizeof(state->audioStreamBasicDescription);
    osStatus = AudioQueueGetProperty(state->audioQueueRef,
                                     kAudioQueueProperty_StreamDescription,
                                     asbd,
                                     &dataFormatSize);
    logOSError(@"startRecording AudioQueueGetProperty",
               osStatus, state->logger);

    if (!state->open_func(state->parameter,
                          asbd,
                          &(state->audioFileID),
                          &(state->audioFileClientData),
                          state->logger)
        ) {
        return NO;
    }
    
    DeriveBufferSize(state->audioQueueRef, asbd, 0.5, &(state->bufferByteSize));

    for(int i=0; i<kInputBufferCount; i++) {
        osStatus = AudioQueueAllocateBuffer(state->audioQueueRef,
                                            state->bufferByteSize,
                                            &(state->inputBuffers[i]));
        logOSError([NSString stringWithFormat:
                    @"%@[%d]", @"startRecording AudioQueueAllocateBuffer", i],
                   osStatus, state->logger);
        
        osStatus = AudioQueueEnqueueBuffer(state->audioQueueRef,
                                           state->inputBuffers[i],
                                           0, NULL);
        logOSError([NSString stringWithFormat:
                    @"%@[%d]", @"startRecording AudioQueueEnqueueBuffer", i],
                   osStatus, state->logger);
    }
    
    [self setUpAVAudioSession:YES];
    
    osStatus = AudioQueueStart(state->audioQueueRef, NULL);
    if (logOSError(@"startRecording AudioQueueStart", osStatus, state->logger)) {
        return NO;
    }
    state->queue_state = backgrounder_queue_state_STARTED;
    
    return YES;
}

-(BOOL)startPlayback
{
    backgrounder_state *state = self.state;
    
    // Following writes a warning to the log, if necessary.
    [self hasBackgroundModeAudio];

    // Open the audio file to read the stream description and other details that
    // are required to set up the audio queue.
    if (!state->open_func(state->parameter,
                          NULL,
                          &(state->audioFileID),
                          &(state->audioFileClientData),
                          state->logger)
        ) {
        return NO;
    }
    
    AudioStreamBasicDescription *asbd = getASBD_malloc(state->audioFileID,
                                                       state->logger );
    if (!asbd) {
        state->logger(@"startPlayback failed to get "
                      "AudioStreamBasicDescription\n");
        return NO;
    }
    
    // Following lines will set values such that the whole file can be loaded
    // into a single buffer. ToDo: Proper implementation with small buffers that
    // get refilled only as needed and are otherwise consumed packet-by-packet.
    state->byteCount =
    getAudioProperty_UInt32(state->audioFileID,
                            kAudioFilePropertyAudioDataByteCount,
                            state->logger );
    
    state->packetCount =
    getAudioProperty_UInt32(state->audioFileID,
                            kAudioFilePropertyAudioDataPacketCount,
                            state->logger );
    
    // Details obtained, leave the file open. It gets closed and re-opened in
    // the queue callback.
    
    // In the following call, state is passed as the inUserData.
    // This makes the backgrounder_state accessible in the queue callback.
    OSStatus osStatus = AudioQueueNewOutput(asbd,
                                            audioQueueOutputCallback,
                                            state,
                                            NULL, NULL, 0,
                                            &(state->audioQueueRef) );
    if (logOSError(@"startPlayback AudioQueueNewOutput(...) failed.",
                   osStatus, state->logger)) {
        return NO;
    }
    
    AudioQueueBufferRef audioQueueBufferRef;
    osStatus =
    AudioQueueAllocateBufferWithPacketDescriptions(state->audioQueueRef,
                                                   state->byteCount,
                                                   state->packetCount,
                                                   &audioQueueBufferRef);
    if (logOSError([NSString
                    stringWithFormat:@"startPlayback "
                    "Audio...BufferWithPacket...s(,%d,%d,)",
                    (unsigned int)state->byteCount,
                    (unsigned int)state->packetCount],
                   osStatus, state->logger)) {
        return NO;
    }
    
    [self setUpAVAudioSession:YES];
    
    // Invoke our own callback to start playback.
    audioQueueOutputCallback(state,
                             state->audioQueueRef,
                             audioQueueBufferRef);
    
    
    return YES;
}

static void backgrounderLoggerDefault(NSString *message)
{
    NSLog(@"%@", message);
};

-(void)setLogger:(backgrounder_logger)logger
{
    // No state yet. Create one with duff values for now so that we have a spot
    // to pin the logger. This malloc is expected to get freed in the resetState
    // that will follow.
    if (!self.state) {
        self.state = malloc(sizeof(backgrounder_state));
        if (self.state) {
            self.state->queue_state = backgrounder_queue_state_STOPPED;
        }
    }
    if (!self.state) {
        logger([NSString stringWithFormat:
                @"%s failed malloc(%lu) for backgrounder_state.\n",
                __PRETTY_FUNCTION__, sizeof(backgrounder_state)]);
    }
    else {
        self.state->logger = logger;
    }
}

+(instancetype)sharedInstance
{
    static Backgrounder *backgrounder = nil;
    static dispatch_once_t onceToken = 0; dispatch_once(&onceToken, ^{
        backgrounder = [[Backgrounder alloc] init]; });
    return backgrounder;
}
-(instancetype)init
{
    self = [super init];
    
    self.state = NULL;

    return self;
}

@end
