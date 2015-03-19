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
#import <GD/GDServices.h>

@interface gdRequest : NSObject

-(instancetype)storeFrom:(gdRequest *)request;
-(NSString *)getServiceID;
-(instancetype)setServiceID:(NSString *)serviceID;
-(NSString *)getServiceVersion;
-(instancetype)setServiceVersion:(NSString *)version;
-(instancetype)addDefinedMethods:(NSArray *)methods;
-(NSArray *)getDefinedMethods;
-(NSString *)getMethod;
-(instancetype)setMethod:(NSString *)method;
-(NSString *)getRequestID;
-(instancetype)setRequestID:(NSString *)requestID;
-(GDTForegroundOption)getForegroundPreference;
-(instancetype)setForegroundPreference:(GDTForegroundOption) value;
-(GDTForegroundOption)getReplyForegroundPreference;
-(instancetype)setReplyForegroundPreference:(GDTForegroundOption) value;
-(instancetype)setParameter:(id)value path:(NSArray *)path;
-(instancetype)setParameter:(id)value;
-(instancetype)setReplyParameter:(id)value path:(NSArray *)path;
-(instancetype)setReplyParameter:(id)value;
-(instancetype)setParameterFromICC:(NSObject *)icc;
-(instancetype)setParameterAppend:(NSArray *)values path:(NSArray *)path;
-(id)getParameter:(NSArray *)param_path;
-(instancetype)addAttachments:(NSArray *)attachments;
-(NSArray *)getAttachments;
-(NSString *)getAttachment;
-(instancetype)addReplyAttachments:(NSArray *)attachments;
-(NSArray *)getReplyAttachments;
-(instancetype)selectProvider:(int)index;
-(instancetype)queryProviders;
-(NSString *)getProvidersDump;
-(NSArray *)getProviderNames;
-(NSArray *)getProviderAddresses;
-(NSString *)getApplication;
-(instancetype)setApplication:(NSString *)application;
-(NSString *)sendOrMessage:(NSError **)error;
-(NSString *)replyOrMessage:(NSError **)error;
@end
