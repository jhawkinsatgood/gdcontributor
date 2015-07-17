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

#import "PathStore.h"

@interface PathStore()
@property (strong, nonatomic) NSMutableDictionary *obj;
@property (strong, nonatomic) NSMutableArray *arr;
-(BOOL) has:(NSObject *)o;
-(NSObject *)opt:(NSObject *)o;
+(NSObject *)JSONSafe:(NSObject *)value;
@end

@implementation PathStore

@synthesize obj;
@synthesize arr;

-(NSString *)description
{
    return [self toJSON];
}

-(instancetype)initAsDictionary
{
    obj = [NSMutableDictionary new];
    arr = nil;
    return self;
}

-(instancetype)initAsArray
{
    obj = nil;
    arr = [NSMutableArray new];
    return self;
}

+(NSObject *)JSONSafe:(NSObject *)value
{
    // It seems to be necessary to put the value into a dictionary for the
    // validity check to pass. This is "strict" JSON, where for example "blib"
    // is not JSON; it's a simple value.
    if ([NSJSONSerialization isValidJSONObject:[NSDictionary
                                                dictionaryWithObject:value
                                                forKey:@"key"]]) {
        return value;
    }
    
    // If we reach this point then the value as is cannot be serialised.
    // Try some fixes, only one at time of writing, or give up.
    if ([value isKindOfClass:[NSData class]]) {
        return [[NSString alloc] initWithData:(NSData *)value
                                     encoding:NSASCIIStringEncoding];
    }

    // Give up and return an error message that is JSON safe.
    return @"Cannot serialise into JSON.";
}

-(NSObject *)toICCObjectForJSON:(BOOL)forJSON
{
    if (obj) {
        NSMutableDictionary *ret = [NSMutableDictionary new];
        [obj enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
            if ([value isKindOfClass:[PathStore class]]) {
                [ret setValue:[(PathStore *)value toICCObjectForJSON:forJSON]
                       forKey:key];
            }
            else {
                if (forJSON) {
                    value = [PathStore JSONSafe:value];
                }
                [ret setValue:value forKey:key];
            }
        }];
        return ret;
    }
    else if (arr) {
        NSMutableArray *ret = [[NSMutableArray alloc]
                               initWithCapacity:[arr count]];
        for (int i=0; i<[arr count]; i++) {
            if ([arr[i] isKindOfClass:[PathStore class]]) {
                [ret addObject:[(PathStore *)(arr[i])
                                toICCObjectForJSON:forJSON]];
            }
            else {
                NSObject *value = arr[i];
                if (forJSON) {
                    value = [PathStore JSONSafe:value];
                }
                [ret addObject:value];
            }
        }
        return ret;
    }
    else {
        return nil;
    }
}

-(NSString *)toJSON
{
    NSObject *icc = [self toICCObjectForJSON:YES];
    if ([NSJSONSerialization isValidJSONObject:icc]) {
        NSData *ret_data = [NSJSONSerialization dataWithJSONObject:icc
                                                           options:0
                                                             error:nil] ;
        return [[NSString alloc] initWithData:ret_data
                                     encoding:NSASCIIStringEncoding];
    }
    else {
        // This should never happen because the validity check is already made
        // in the toICCObjectForJSON function.
        return @"Cannot serialise into JSON.";
    }
}

-(BOOL) isArray {
    return arr != nil;
}

-(BOOL) sameType:(NSObject *)that {
    if (![that isKindOfClass:[self class]]) {
        return NO;
    }
    else {
        return [((PathStore *)that) isArray] == [self isArray];
    }
}

-(instancetype)put:(NSObject *)o value:(NSObject *)value
{
    if ([o isKindOfClass:[NSString class]]) {
        arr = nil;
        if (!obj) obj = [NSMutableDictionary new];
        [obj setValue:value forKey:(NSString *)o];
    }
    else if ([o isKindOfClass:[NSNumber class]]) {
        obj = nil;
        int index = [(NSNumber *)o intValue];
        // If there is no array then allocate it now
        if (!arr) {
            arr = [[NSMutableArray alloc] initWithCapacity:index+1];
        }
        // Pad the array out to whatever size is needed
        while (index >= [arr count]) {
            [arr addObject:[NSNull new]];
        }
        // Set the value
        arr[index] = value;
    }
    return self;
}

-(NSUInteger)length
{
    if (arr) {
        return [arr count];
    }
    else {
        return 0;
    }
}

-(BOOL)has:(NSObject *)o
{
    if (obj && [o isKindOfClass:[NSString class]]) {
        return [obj valueForKey:(NSString *)o] != nil;
    }
    else if (arr && [o isKindOfClass:[NSNumber class]]) {
        int index = [(NSNumber *)o intValue];
        return index >= 0 && index < [arr count];
    }
    else {
        return NO;
    }
}

-(NSObject *)opt:(NSObject *)o
{
    if (obj && [o isKindOfClass:[NSString class]]) {
        return [obj valueForKey:(NSString *)o];
    }
    else if (arr && [o isKindOfClass:[NSNumber class]]) {
        return arr[[(NSNumber *)o intValue]];
    }
    else {
        return nil;
    }
}

-(id)pathGet:(id)path0, ...
{
    va_list paths;
    va_start(paths, path0);
    id ret = [self pathGetv:path0 arguments:paths];
    va_end(paths);
    return ret;
}

-(id)pathGetv:(id)path0 arguments:(va_list)paths
{
    if (!path0) return self;
    NSMutableArray *paths_array = [NSMutableArray new];
    for (id path = path0; path; path = va_arg(paths, id)) {
        [paths_array addObject:path];
    }
    return [self pathGeta:paths_array];
}

-(id)pathGeta:(NSArray *)paths
{
    PathStore *get_point = self;
    id ret = nil;
    for(int i=0; get_point; i++) {
        /* Check if the end of the path has been reached.
         * If it has, get now and return.
         */
        if (i+1 >= [paths count]) {
            ret = [get_point opt:paths[i]];
            break;
        }
        
        /* If we get here, then we will be going around the loop again
         * and descending.
         *
         * First check if the thing into which we are descending is
         * missing. If it is, stop descending.
         */
        if (![get_point has:paths[i]]) break;
        id next = [get_point opt:paths[i]];
        
        /* Construct a blank thing to check the next thing is of the
         * expected type.
         */
        PathStore *checker = [PathStore alloc];
        if ([paths[i+1] isKindOfClass:[NSNumber class]]) {
            checker = [checker initAsArray];
        }
        else {
            checker = [checker initAsDictionary];
        }
        
        /* Check the next thing is of the expected type.
         * If it isn't, stop descending.
         */
        if (![checker sameType:next]) break;
        
        /* Descend.
         */
        get_point = (PathStore *)next;
    }
    return ret;
}

-(NSString *)pathGetString:(id)path0, ...
{
    va_list paths;
    va_start(paths, path0);
    id ret = [self pathGetv:path0 arguments:paths];
    va_end(paths);
    if ([ret isKindOfClass:[NSString class]]) {
        return (NSString *)ret;
    }
    else {
        return nil;
    }
}

-(NSNumber *)pathGetNumber:(id)path0, ...
{
    va_list paths;
    va_start(paths, path0);
    id ret = [self pathGetv:path0 arguments:paths];
    va_end(paths);
    if ([ret isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)ret;
    }
    else {
        return nil;
    }
}

-(NSArray *)pathGetArray:(id)path0, ...
{
    va_list paths;
    va_start(paths, path0);
    id value = [self pathGetv:path0 arguments:paths];
    va_end(paths);

    if (!value) return nil;

    if ([value isKindOfClass:[NSString class]]) {
        return @[ (NSString *)value ];
    }
    if (![value isKindOfClass:[PathStore class]]) {
        return nil;
    }
    PathStore *value_path = (PathStore *)value;
    if (![value_path isArray]) return nil;
    
    NSUInteger value_length = [value_path length];
    if (value_length <= 0) return nil;
    
    BOOL allNull = true;
    NSMutableArray *ret = [NSMutableArray new];
    for (int stringi =0; stringi < value_length; stringi++) {
        NSString *istring = [value_path
                             pathGetString:[NSNumber numberWithInt:stringi],
                             nil];
        allNull = allNull && (istring == nil);
        if (istring) {
            [ret addObject:istring];
        }
        else {
            [ret addObject:[NSNull new]];
        }
    }
    if (allNull) return nil;
    return ret;
}

-(instancetype)pathSet:(id)value, ...
{
//    NSMutableArray *paths_array = [NSMutableArray new];
    va_list paths;
    va_start(paths, value);
    id ret = [self pathSet:value v:paths];
//    for (id path = va_arg(paths, id); path; path = va_arg(paths, id)) {
//        [paths_array addObject:path];
//    }
    va_end(paths);
    return ret;
}

-(instancetype)pathSet:(id)value v:(va_list)paths
{
    NSMutableArray *paths_array = [NSMutableArray new];
    for (id path = va_arg(paths, id); path; path = va_arg(paths, id)) {
        [paths_array addObject:path];
    }
    return [self pathSet:value a:paths_array];
}

-(instancetype)pathSet:(id)value a:(NSArray *)paths
{
    if ([paths count] < 1) {
        assert(@"Cannot pathSet: with empty paths.");
    }
    PathStore *set_point = self;
    int i = 0;
    for(;;) {
        id pathi = paths[i];
        /* If we are in an array, then the path will be a numeric index.
         * In that case, check if it is negative. A negative index means
         * append to the end of the array.
         */
        if ([pathi isKindOfClass:[NSNumber class]]) {
            if ([(NSNumber *)pathi intValue] < 0) {
                pathi = [NSNumber numberWithInteger:[set_point length]];
            }
            // pathi will be 0 if set_point is not an array.
        }

        /* Check if the end of the path has been reached.
         * If it has, set now and return.
         */
        if (i+1 >= [paths count]) {
            [set_point put:pathi value:value];
            break;
        }
        
        /* If we get here, then we will be going around the loop again
         * and descending.
         *
         * First check if the thing into which we are descending is
         * missing. If it isn't missing, get a reference to it.
         */
        BOOL absent = ![set_point has:pathi];
        NSObject *checker = nil;
        if (!absent) {
            checker = [set_point opt:pathi];
        }
        
        /* Construct a candidate blank thing in case it is needed.
         * Creating the object here avoids a nested if later.
         */
        PathStore *next = [PathStore alloc];
        if ([paths[i+1] isKindOfClass:[NSNumber class]]) {
            next = [next initAsArray];
        }
        else {
            next = [next initAsDictionary];
        }
        
        /* Put the candidate blank thing in place, if necessary.
         * It is necessary if there is no thing into which to descend,
         * or if the current thing is of the wrong type.
         */
        if (absent || ![next sameType:checker]) {
            [set_point put:pathi value:next];
        }
        
        /* Descend.
         */
        set_point = (PathStore *)[set_point opt:pathi];
        i++;
    }
    return self;
}

-(instancetype)pathSetAppend:(id)value a:(NSArray *)paths
{
    NSMutableArray *paths1 = [NSMutableArray arrayWithArray:paths];
    // Next line contains a literal for the NSNumber representation of minus one
    [paths1 addObject:@-1];
    return [self pathSet:value a:paths1];
}

-(instancetype)pathSetAppendAll:(NSArray *)values a:(NSArray *)paths
{
    NSMutableArray *paths1 = [NSMutableArray arrayWithArray:paths];
    // Next line contains a literal for the NSNumber representation of minus one
    [paths1 addObject:@-1];
    for (int i=0; i < [values count]; i++) {
        [self pathSet:values[i] a:paths1];
    }
    return self;
}

+(NSObject *)createFromICC:(NSObject *)from
{
    if ([from isKindOfClass:[NSDictionary class]]) {
        PathStore *ret = [[PathStore alloc] initAsDictionary];
        [(NSDictionary *)from
         enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop){
             [ret pathSet:[PathStore createFromICC:obj], key, nil];
         }];
        return ret;
    }
    else if ([from isKindOfClass:[NSArray class]]) {
        PathStore *ret = [[PathStore alloc] initAsArray];
        NSArray *from_array = (NSArray *)from;
        for (int i=0; i<from_array.count; i++) {
            [ret pathSet:[PathStore createFromICC:from_array[i]],
             [NSNumber numberWithInt:i], nil];
        }
        return ret;
    }
    else {
        return from;
    }
}

@end
