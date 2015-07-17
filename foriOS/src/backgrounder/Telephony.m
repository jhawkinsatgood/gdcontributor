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

#import "Telephony.h"
@import CoreTelephony;

@interface Telephony ()
@property(assign, nonatomic) telephony_logger telephonyLogger;
@property(strong, nonatomic) CTTelephonyNetworkInfo *ctTelephonyNetworkInfo;
@property(assign, nonatomic) BOOL observing;
@end

@implementation Telephony

-(void)observeNotification:(NSNotification *)nsNotification
{
    // Adding any calls to the CTTelephonyNetworkInfo API in here, even
    // allocating a new one in the scope of this function, seemed to cause a lot
    // threads to spawn and dispatch the notification again and again.
    //
    // If a new one is allocated and there is no SIM inserted then some values
    // in the object, for example the MCC and MNC, are null.
    
    self.telephonyLogger([NSString
                          stringWithFormat:
                          @"Telephony observeNotification.\n\"%@\"\n\"%@\"\n",
                          nsNotification.name,
                          nsNotification.object ]);
}

-(void)start:(telephony_logger)logger
{
    if (!logger) {
        logger = TELEPHONY_LOGGER(nsString) {
            NSLog(@"%@", nsString);
        };
    }

    // It seems to be necessary to stop observing during any use of the
    // CTTelephonyNetworkInfo API. Otherwise the observer gets dispatched many
    // times, on different threads.
    if (self.observing) {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:CTRadioAccessTechnologyDidChangeNotification
         object:nil];
        self.observing = NO;
    }
    
    self.telephonyLogger = logger;

    self.ctTelephonyNetworkInfo = [CTTelephonyNetworkInfo new];

    self.telephonyLogger([NSString
                          stringWithFormat:@"Telephony starting.\n\"%@\"\n%@\n",
                          
                          self.ctTelephonyNetworkInfo
                          .currentRadioAccessTechnology,
                          
                          self.ctTelephonyNetworkInfo
                          .subscriberCellularProvider ]);

    // The following hasn't been tested beyond discovering that the notification
    // doesn't seem to be dispatched when the SIM is inserted or removed.
    //
    // self.ctTelephonyNetworkInfo.subscriberCellularProviderDidUpdateNotifier =
    // ^void (CTCarrier *ctCarrier) {
    //     logger([NSString stringWithFormat:
    //             @"subscriberCellularProviderDidUpdate to:\n%@\n", ctCarrier ]);
    // };
    //
    // It would be impossible to change the SIM without the radio access
    // technology changing anyway, so the following notification works more
    // generally.
    
    // The following notification is dispatched when the SIM is inserted or
    // removed, as well as when the radio access technology changes. Actually,
    // it seems to be dispatched multiple times when the SIM is inserted, which
    // could maybe be the device renegotiating with the carrier network.
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(observeNotification:)
     name:CTRadioAccessTechnologyDidChangeNotification
     object:nil];
    self.observing = YES;
}

-(void)dealloc
{
    if (self.observing) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.observing = NO;
    }
}

@end
