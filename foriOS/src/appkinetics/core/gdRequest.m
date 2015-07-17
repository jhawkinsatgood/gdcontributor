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

#import "gdRequest.h"
#import "PathStore.h"

#import <GD/GDiOS.h>
#import <GD/GDAppDetail.h>

@interface gdRequest()
@property(strong, nonatomic) PathStore *store;
-(void) _setParameter:(id)value top:(NSArray *)top path:(NSArray *)path;
-(void) _setParameterAppend:(NSArray *)values top:(NSArray *)top path:(NSArray *)path;
-(id)getSendParameter;
-(id)getReplyParameter;
-(NSArray *)_getProviderDetails:(NSString *)detail;
-(NSString *)getProviderAddress;
@end

@implementation gdRequest

@synthesize store;

- (instancetype) init
{
    self = [super init];
    store = [[PathStore alloc] initAsDictionary];
    return self;
}

-(NSString *)description
{
    return [store description];
}

-(instancetype)storeFrom:(gdRequest *)request
{
    store = request.store;
    return self;
}

-(NSString *)getServiceID {
    return [store pathGetString:@"Definition", @"service-id", nil];
}
-(instancetype)setServiceID:(NSString *)serviceID {
    [store pathSet:serviceID a:@[@"Definition", @"service-id"]];
    return self;
}

-(NSString *)getServiceVersion {
        return [store pathGetString:@"Definition", @"version", nil];
    }
-(instancetype) setServiceVersion:(NSString *)version {
        [store pathSet:version a:@[@"Definition", @"version"]];
        return self;
    }

-(instancetype)addDefinedMethods:(NSArray *)methods {
    [store pathSetAppendAll:methods a:@[@"Definition", @"methods"]];
    return self;
}
-(NSArray *)getDefinedMethods {
    return [store pathGetArray:@"Definition", @"methods", nil];
}


-(NSString *)getMethod {
    return [store pathGetString:@"Request", @"Method", nil];
}
-(instancetype)setMethod:(NSString *)method {
    [store pathSet:method a:@[@"Request", @"Method"]];
    return self;
}

-(NSString *)getRequestID {
    return [store pathGetString:@"Request", @"ID", nil];
}
-(instancetype) setRequestID:(NSString *)requestID {
    [store pathSet:requestID a:@[@"Request", @"ID"]];
    return self;
}

-(GDTForegroundOption)getForegroundPreference {
    return (GDTForegroundOption)[[store pathGetNumber:
                                 @"Request", @"ForegroundPreference", nil]
                                 intValue];
}
-(instancetype) setForegroundPreference:(GDTForegroundOption) value {
    [store pathSet:[NSNumber numberWithInt:value]
         a:@[@"Request", @"ForegroundPreference"]];
    return self;
}

-(GDTForegroundOption)getReplyForegroundPreference {
    return (GDTForegroundOption)[store pathGetNumber:
                                 @"Reply", @"ForegroundPreference", nil];
}
-(instancetype) setReplyForegroundPreference:(GDTForegroundOption) value {
    [store pathSet:[NSNumber numberWithInt:value]
         a:@[@"Reply", @"ForegroundPreference"]];
    return self;
}

-(void) _setParameter:(id)value top:(NSArray *)top path:(NSArray *)path
{
    if ([path count] <= 0) {
        // Simple parameter, just set it
        [store pathSet:value a:top];
    }
    else {
        // Complex parameter, see if there already are complex parameters
        NSObject *paramo = [store pathGeta:top];
        if (paramo && [paramo isKindOfClass:[PathStore class]]) {
            // Already have complex parameters, add this one.
            [(PathStore *)paramo pathSet:value a:path];
        }
        else {
            // No parameters set yet, or current parameter is simple.
            // Create a new StorePath for the parameters and put them in.
            [store pathSet:[[[PathStore alloc] initAsDictionary] pathSet:value
                                                                  a:path]
                     a:top];
        }
    }
}

// This method is the same as setParameter but calls pathSetAppend instead
// of pathSet where appropriate.
-(void) _setParameterAppend:(NSArray *)values top:(NSArray *)top path:(NSArray *)path
{
    if ([path count] <= 0) {
        // Simple parameter, just set it
        [store pathSetAppendAll:values a:top];
    }
    else {
        // Complex parameter, see if there already are complex parameters
        NSObject *paramo = [store pathGeta:top];
        if (paramo && [paramo isKindOfClass:[PathStore class]]) {
            // Already have complex parameters, add this one.
            [(PathStore *)paramo pathSetAppendAll:values a:path];
        }
        else {
            // No parameters set yet, or current parameter is simple.
            // Create a new StorePath for the parameters and put them in.
            [store pathSet:[[[PathStore alloc] initAsDictionary] pathSetAppendAll:values
                                                                           a:path]
                     a:top];
        }
    }
}

-(instancetype)setParameter:(id)value path:(NSArray *)path
{
    [self _setParameter:value top:@[@"Request", @"Parameter"] path:path];
    return self;
}

-(instancetype)setParameter:(id)value
{
    return[self setParameter:value path:@[]];
}

-(instancetype)setReplyParameter:(id)value path:(NSArray *)path
{
    [self _setParameter:value top:@[@"Reply", @"Parameter"] path:path];
    return self;
}

-(instancetype)setReplyParameter:(id)value
{
    return [self setReplyParameter:value path:@[]];
}

-(instancetype)setParameterFromICC:(NSObject *)icc
{
    [store pathSet:[PathStore createFromICC:icc], @"Request", @"Parameter", nil];
    return self;
}

-(instancetype)setParameterAppend:(NSArray *)values path:(NSArray *)path
{
    [self _setParameterAppend:values top:@[@"Request", @"Parameter"] path:path];
    return self;
}

-(id)getParameter:(NSArray *)param_path
{
    id paramo = [store pathGeta:@[@"Request", @"Parameter"]];
    if ([paramo isKindOfClass:[PathStore class]]) {
        return [(PathStore *)paramo pathGeta:param_path];
    }
    else {
        return paramo;
    }
}

-(id)getSendParameter
{
    NSObject *paramo = [store pathGet:@"Request", @"Parameter", nil];
    if (paramo && [paramo isKindOfClass:[PathStore class]]) {
        return [(PathStore *)paramo toICCObjectForJSON:NO];
    }
    else {
        return paramo;
    }
}

-(id)getReplyParameter
{
    NSObject *paramo = [store pathGet:@"Reply", @"Parameter", nil];
    if (paramo && [paramo isKindOfClass:[PathStore class]]) {
        return [(PathStore *)paramo toICCObjectForJSON:NO];
    }
    else {
        return paramo;
    }
}

-(instancetype)addAttachments:(NSArray *)attachments
{
    [store pathSetAppendAll:attachments a:@[@"Request", @"Attachments" ]];
    return self;
}
-(NSArray *)getAttachments
{
    return [store pathGetArray:@"Request", @"Attachments", nil];
}
-(NSString *)getAttachment
{
    // Next line contains a literal for the NSNumber representation of zero.
    return [store pathGetString:@"Request", @"Attachments", @0, nil];
}

-(instancetype)addReplyAttachments:(NSArray *)attachments
{
    [store pathSetAppendAll:attachments a:@[@"Reply", @"Attachments"]];
    return self;
}
-(NSArray *)getReplyAttachments
{
    return [store pathGetArray:@"Reply", @"Attachments", nil];
}

-(instancetype)selectProvider:(int)index
{
    [store pathSet:[NSNumber numberWithInt:index]
         a:@[@"Request", @"Provider", @"Selected"]];
    [self setApplication:[self getProviderAddress]];
    return self;
}
-(instancetype)queryProviders
{
    // Execute an AppKinetics service discovery query.
    NSArray *provider_details = [[GDiOS sharedInstance]
                                 getServiceProvidersFor:[self getServiceID]
                                 andVersion:[self getServiceVersion]
                                 andType:GDServiceProviderApplication];

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *exclude = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    NSUInteger provider_count = 0;
    
    // Store the results in an array in the StorePath
    for (int i=0; i<[provider_details count]; i++) {
        GDServiceProvider *provideri = provider_details[i];
        
        if ([exclude isEqualToString:[provideri address]]) {
            continue;
        }
        
        [store pathSet:[[[[[[PathStore alloc] initAsDictionary]
                    pathSet:[provideri identifier], @"identifier", nil]
                    pathSet:[provideri name], @"name", nil]
                    pathSet:[provideri address], @"address", nil]
                    pathSet:[provideri version], @"version", nil]
                 a:@[@"Request", @"Provider", @"Query",
                     [NSNumber numberWithInteger:provider_count]]];
        provider_count++;
    }

    if (provider_count == 1) {
        [self selectProvider:0];
    }
    
    return self;
}
-(NSString *)getProvidersDump
{
    return [[store pathGet:@"Request", @"Provider", @"Query", nil] description];
}
-(NSArray *)_getProviderDetails:(NSString *)detail
{
    NSObject *providers_object =
    [store pathGet:@"Request", @"Provider", @"Query", nil];
    if (![providers_object isKindOfClass:[PathStore class]]) {
        // Return an empty array.
        return @[];
    }
    
    PathStore *providers = (PathStore *)providers_object;
    NSUInteger providers_length = [providers length];
    // Next line returns an empty array.
    if (providers_length <= 0) return @[];
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:providers_length];
    for (int i=0; i<providers_length; i++) {
        ret[i] = [providers pathGetString:
                  [NSNumber numberWithInt:i], detail, nil];
    }
    return ret;
}
-(NSArray *)getProviderNames
{
    return [self _getProviderDetails:@"name"];
}
-(NSArray *)getProviderAddresses
{
    return [self _getProviderDetails:@"address"];
}

-(NSString *)getProviderAddress
{
    NSNumber *provideri = [store pathGetNumber:
                           @"Request", @"Provider", @"Selected", nil];
    if (!provideri) return nil;
    return [store pathGetString:
            @"Request", @"Provider", @"Query", provideri, @"address", nil];
}

-(NSString *)getApplication
{
    return [store pathGetString:@"Request", @"Application", nil];
}
-(instancetype)setApplication:(NSString *)application
{
    [store pathSet:application, @"Request", @"Application", nil];
    return self;
}

-(NSString *)sendOrMessage:(NSError **)error
{
    if (![self getApplication]) {
        [self queryProviders];
        NSString *provider = [self getProviderAddress];
        if (!provider) {
            NSString *message = @"Provider is null.";
            if (error) {
                *error =
                [NSError errorWithDomain:@"gdRequest"
                                    code:1
                                userInfo:@{NSLocalizedDescriptionKey:
                                               message}];
            }
            return message;
        }
        [self setApplication:provider];
    }
    
    NSError *myError;
    NSString *requestID;
    BOOL sendOK = [GDServiceClient sendTo:[self getApplication]
                              withService:[self getServiceID]
                              withVersion:[self getServiceVersion]
                               withMethod:[self getMethod]
                               withParams:[self getSendParameter]
                          withAttachments:[self getAttachments]
                      bringServiceToFront:[self getForegroundPreference]
                                requestID:&requestID
                                    error:&myError];
    [self setRequestID:requestID];

    if (sendOK) return nil;

    // Send failed.
    if (error) *error = myError;
    [store pathSet:[myError description], @"Request", @"LastError", nil];
    return [myError description];
}

-(NSString *)replyOrMessage:(NSError **)error
{
    NSError *myError;
    BOOL replyOK = [GDService replyTo:[self getApplication]
                           withParams:[self getReplyParameter]
                   bringClientToFront:[self getReplyForegroundPreference]
                      withAttachments:[self getReplyAttachments]
                            requestID:[self getRequestID]
                                error:&myError];
    if (replyOK) return nil;
    
    // Reply failed
    if (error != nil) *error = myError;
    [store pathSet:[myError description], @"Reply", @"LastError", nil];
    return [myError description];
}

@end
