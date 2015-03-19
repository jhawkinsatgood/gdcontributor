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

#import "gdProvider.h"
#import "gdDispatcher.h"

@interface gdProvider()
@property(strong, nonatomic) NSMutableArray *listeners;
@property(strong, nonatomic) gdRequest *template;
@property(strong, nonatomic) NSNumber *registered;
@end

@implementation gdProvider

@synthesize listeners;
@synthesize template;
@synthesize registered;

//BOOL registered = NO;

-(instancetype)init
{
    self = [super init];
    listeners = [NSMutableArray new];
    template = [gdRequest new];
    registered = [NSNumber numberWithBool:NO];
    return self;
}

-(NSString *)description
{
    return [template description];
}

-(NSString *)getServiceID {
    return [template getServiceID];
}
-(instancetype)setServiceID:(NSString *)serviceID {
    [template setServiceID:serviceID];
    return self;
}

-(NSString *)getServiceVersion {
    return [template getServiceVersion];
}
-(instancetype) setServiceVersion:(NSString *)version {
    [template setServiceVersion:version];
    return self;
}

-(instancetype)addDefinedMethods:(NSArray *)methods {
    [template addDefinedMethods:methods];
    return self;
}
-(NSArray *)getDefinedMethods {
    return [template getDefinedMethods];
}

-(instancetype)addListener:(gdProviderListener)listener
{
    [listeners addObject:listener];
    // Register when the first listener is added.
    if (![registered boolValue]) {
        [[gdDispatcher sharedInstance] register:self];
        registered = [NSNumber numberWithBool:YES];
    }
    return self;
}

-(gdRequest *)onReceiveRequest:(gdRequest *)request
{
    for (int i=0; i<listeners.count; i++) {
        gdProviderListener listeneri = (gdProviderListener)listeners[i];
        request = listeneri(request);
        if (!request) break;
    }
    return request;
}

@end
