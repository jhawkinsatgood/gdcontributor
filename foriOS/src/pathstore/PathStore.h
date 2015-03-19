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

@interface PathStore : NSObject
-(NSString *)description;
-(instancetype)initAsDictionary;
-(instancetype)initAsArray;
-(NSString *)toJSON;
-(NSObject *)toICCObjectForJSON:(BOOL)forJSON;
-(BOOL)isArray;
-(BOOL)sameType:(NSObject *)that;
-(instancetype)put:(NSObject *)o value:(NSObject *)value;
-(int)length;
-(id)pathGet:(id)path0, ...;
-(id)pathGetv:(id)path0 arguments:(va_list)paths;
-(id)pathGeta:(NSArray *)paths;
-(NSNumber *)pathGetNumber:(id)path0, ...;
-(NSString *)pathGetString:(id)path0, ...;
-(NSArray *)pathGetArray:(id)path0, ...;
-(instancetype)pathSet:(id)value, ...;
-(instancetype)pathSet:(id)value v:(va_list)paths;
-(instancetype)pathSet:(id)value a:(NSArray *)paths;
-(instancetype)pathSetAppend:(id)value a:(NSArray *)paths;
-(instancetype)pathSetAppendAll:(NSArray *)values a:(NSArray *)paths;
+(NSObject *)createFromICC:(NSObject *)from;
@end
