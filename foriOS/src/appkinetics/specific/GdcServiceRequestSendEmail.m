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

#import "GdcServiceRequestSendEmail.h"

@implementation GdcServiceRequestSendEmail

-(instancetype)init
{
    self = [super init];
    self.serviceID = @"com.good.gfeservice.send-email";
    self.serviceVersion = @"1.0.0.0";
    self.method = @"sendEmail";
    self.foregroundPreference = GDEPreferPeerInForeground;
    return self;
}

-(instancetype)addToAddresses:(NSArray *)addresses {
    return[self setParameterAppend:addresses path:@[@"to"]];
}
-(instancetype)addCcAddresses:(NSArray *)addresses {
    return[self setParameterAppend:addresses path:@[@"cc"]];
}
-(instancetype)addBccAddresses:(NSArray *)addresses {
    return[self setParameterAppend:addresses path:@[@"bcc"]];
}
-(instancetype)setSubject:(NSString *)subject {
    return[self setParameter:subject path:@[@"subject"]];
}
-(instancetype)setBody:(NSString *)body {
    return[self setParameter:body path:@[@"body"]];
}

@end
