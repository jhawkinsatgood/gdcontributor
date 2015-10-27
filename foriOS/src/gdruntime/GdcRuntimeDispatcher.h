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
#import <Foundation/NSNotification.h>
#import <GD/GDiOS.h>

/** Type for a code block to process a GDAppEvent.
 */
typedef void (^GdcRuntimeEventObserver)(GDAppEvent *);

/** MACRO to facilitate creating code blocks of this type.
 */
#define GDC_RUNTIME_OBSERVER(EVENT) ^void (GDAppEvent *EVENT)

/** Type for a code block to process a configuration update.
 */
typedef void (^GdcConfigurationObserver)(NSDictionary *, NSString *);

/** MACRO to facilitate creating code blocks of this type.
 */
#define GDC_CONFIGURATION_OBSERVER(DICTIONARY,STRING) \
    ^void (NSDictionary * DICTIONARY, NSString * STRING)

@interface GdcRuntimeDispatcher : NSObject <GDiOSDelegate>

+(instancetype)sharedInstance;

@property (strong, nonatomic) NSNotificationCenter *notificationCentre;

-(id)addObserverForEventType:(GDAppEventType)type
                  usingBlock:(GdcRuntimeEventObserver)block;
-(id)addObserverForApplicationPolicy:(GdcConfigurationObserver)block
                        andInvokeNow:(BOOL)invokeNow;
-(id)addObserverForApplicationConfiguration:(GdcConfigurationObserver)block
                               andInvokeNow:(BOOL)invokeNow;

+(NSString *)nameForEvent:(GDAppEventType)type;

+(NSString *)JSONStringFrom:(NSDictionary *)dictionary;
+(NSObject *)JSONItemFrom:(NSObject *)value;
+(NSInteger)addDictionariesFromJSON:(NSMutableDictionary *)dictionary
                         withSuffix:(NSString *)suffix;

+(NSDictionary *)gdApplicationConfigWithoutDeprecations;

@end
