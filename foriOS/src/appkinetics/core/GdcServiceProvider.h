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
#import "GdcServiceRequest.h"

/** Type for a code block to process a received request.
 */
typedef GdcServiceRequest *(^GdcServiceProviderListener)(GdcServiceRequest *);
#define GDC_SERVICE_PROVIDER_LISTENER(REQUEST) \
    ^GdcServiceRequest *(GdcServiceRequest *REQUEST)

@interface GdcServiceProvider : NSObject
-(instancetype)init;
-(NSString *)description;

@property (nonatomic)NSString *serviceID;
@property (nonatomic)NSString *serviceVersion;
@property (nonatomic)NSArray *definedMethods;

-(instancetype)addListener:(GdcServiceProviderListener)listener;
-(GdcServiceRequest *)onReceiveRequest:(GdcServiceRequest *)request;
@end
