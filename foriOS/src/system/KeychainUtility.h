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

/** Utility class for the Keychain.
 * 
 * With thanks to:
 * -   The Security Framework Reference in the iOS Developer Library here:
 *     https://developer.apple.com/library/ios/documentation/Security/Reference/SecurityFrameworkReference/index.html
 * 
 * -   The Core Foundation Reference in the iOS Developer Library here:
 *     https://developer.apple.com/library/ios/documentation/CoreFoundation/Reference/CoreFoundation_Collection/index.html#//apple_ref/doc/uid/TP40003849
 * 
 * -   The header file Frameworks/Security/SecItem.h
 */
@interface KeychainUtility : NSObject

+(NSString *)dumpConstantSymbols;

+(NSString *)keychainDump;

+(NSString *)keychainDumpClass:(CFTypeRef)secClass
                  runningTotal:(NSUInteger *)runningTotal;

+(BOOL)keychainErase:(NSString **)errorMessage;

+(BOOL)keychainEraseClass:(CFTypeRef)secClass
             errorMessage:(NSString **)errorMessage;

@end
