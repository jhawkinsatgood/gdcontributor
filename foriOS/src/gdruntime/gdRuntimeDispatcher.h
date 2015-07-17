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

#import <Foundation/Foundation.h>
#import <Foundation/NSNotification.h>
#import <GD/GDiOS.h>

/** Type for a code block to process a GDAppEvent.
 */
typedef void (^gdRuntimeEventObserver)(GDAppEvent *);

/** MACRO to facilitate creating code blocks of this type.
 */
#define GDRUNTIMEOBSERVER(EVENT) ^void (GDAppEvent *EVENT)

/** Type for a code block to process a configuration update.
 */
typedef void (^gdConfigurationObserver)(NSDictionary *, NSString *);

/** MACRO to facilitate creating code blocks of this type.
 */
#define GDCONFIGURATIONOBSERVER(DICTIONARY,STRING) \
    ^void (NSDictionary * DICTIONARY, NSString * STRING)

@interface gdRuntimeDispatcher : NSObject <GDiOSDelegate>

+(instancetype)sharedInstance;

@property (strong, nonatomic) NSNotificationCenter *notificationCentre;

-(id)addObserverForEventType:(GDAppEventType)type
                  usingBlock:(gdRuntimeEventObserver)block;
-(id)addObserverForApplicationPolicy:(gdConfigurationObserver)block
                        andInvokeNow:(BOOL)invokeNow;
-(id)addObserverForApplicationConfiguration:(gdConfigurationObserver)block
                               andInvokeNow:(BOOL)invokeNow;

+(NSString *)nameForEvent:(GDAppEventType)type;

+(NSString *)JSONStringFrom:(NSDictionary *)dictionary;
+(NSObject *)JSONItemFrom:(NSObject *)value;
+(NSInteger)addDictionariesFromJSON:(NSMutableDictionary *)dictionary
                         withSuffix:(NSString *)suffix;

+(NSDictionary *)gdApplicationConfigWithoutDeprecations;

@end
