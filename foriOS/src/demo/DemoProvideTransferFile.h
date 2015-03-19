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
#import "DemoComponent.h"
#import "DemoComponent-protocol.h"

/** Provide the Transfer File service for diagnostic and illustration purposes.
 * This class illustrates use of the ProvideTransferFile class.
 */
@interface DemoProvideTransferFile : DemoComponent <DemoComponent>

//- (void) setReceiver:(DemoProvideTransferFileLogger)logger;
/**< Illustrative service provider.
 * Call this function to set an illustrative implementation of the service,
 * which logs a stat of the received file and the initial bytes.
 *
 * \param logger Code block to print log messages. The block must conform to the
 *               Logger type. The block will be invoked a number of times every
 *               time a service request is received. It will be passed a
 *               messsage to log as an NSString * parameter on each invocation.
 */

//- (void) setReceiver;
/**< Illustrative service provider that utilises NSLog.
 * Calling this function is equivalent to calling setReceiver: with a block that
 * utilises NSLog to print messages.
 */

@end
