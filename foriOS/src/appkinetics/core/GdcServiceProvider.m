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

#import "GdcServiceProvider.h"
#import "GdcServiceDispatcher.h"

@interface GdcServiceProvider()
@property (nonatomic) NSMutableArray *listeners;
@property (nonatomic) GdcServiceRequest *template;
@property (assign) BOOL registered;
@end

@implementation GdcServiceProvider

-(instancetype)init
{
    self = [super init];
    _listeners = [NSMutableArray new];
    _template = [GdcServiceRequest new];
    _registered = NO;
    return self;
}

-(NSString *)description
{
    return [self.template description];
}

-(NSString *)serviceID {
    return self.template.serviceID;
}
-(void)setServiceID:(NSString *)serviceID {
    self.template.serviceID = serviceID;
}

-(NSString *)serviceVersion {
    return self.template.serviceVersion;
}
-(void)setServiceVersion:(NSString *)version {
    self.template.serviceVersion = version;
}

-(NSArray *)definedMethods {
    return self.template.definedMethods;
}
-(void)setDefinedMethods:(NSArray *)methods {
    self.template.definedMethods = methods;
}

-(instancetype)addListener:(GdcServiceProviderListener)listener
{
    [self.listeners addObject:listener];
    // Register when the first listener is added.
    if (!self.registered) {
        [[GdcServiceDispatcher sharedInstance] register:self];
        self.registered = YES;
    }
    return self;
}

-(GdcServiceRequest *)onReceiveRequest:(GdcServiceRequest *)request
{
    for (int i=0; i<self.listeners.count; i++) {
        GdcServiceProviderListener listeneri =
        (GdcServiceProviderListener)self.listeners[i];
        request = listeneri(request);
        if (!request) break;
    }
    return request;
}

@end
