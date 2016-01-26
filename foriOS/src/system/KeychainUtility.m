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

#import "KeyChainUtility.h"

#import <Security/Security.h>

@implementation KeychainUtility

/** Note on the C language features used in this source file.
 * This source file uses the following features:
 *
 * -   Compile-time string concatenation.
 *
 *     Adjacent C strings are concatenated at compile time. By example:
 *
 *         char *willHoldabcde = "ab" "c" "de";
 *
 * -   Token concatenation: the ## operator.
 *
 *     The compile-time operator ## joins tokens together. This can be
 *     useful in MACRO definitions. By example:
 *
 *         int abelnumber = 1;
 *         char *abelname = "Abel";
 *         int bakernumber = 2;
 *         char *bakername = "Baker";
 *
 *         #define NUMBERFOR(DESIGNATION) DESIGNATION ## number
 *         #define NAMEFOR(DESIGNATION) DESIGNATION ## name
 *
 *         int gets2 = NUMBERFOR(baker);
 *         char *getsBaker = NAMEFOR(baker);
 *         int *pointsTo_abelnumber = & NUMBERFOR(abel) ;
 *
 * -   Stringify: the # operator.
 *
 *     The compile-time unary operator # changes the following token into a
 *     string. This can be useful in MACRO definitions. By example:
 *
 *         #define PRINTF_NAME_AND_VALUE(DESIGNATION) \
 *             printf( "%s: %d\n", # DESIGNATION, DESIGNATION )
 *             
 *         int charlie = 3;
 *         int delta = 4;
 *         PRINTF_NAME_AND_VALUE(charlie);
 *         PRINTF_NAME_AND_VALUE(delta);
 *
 *     The above code prints the following:
 *
 *         charlie: 3
 *         delta: 4
 */

#define SEC_OSSTATUS_TABLE \
    TABLE( noErr ) \
    TABLE( errSecSuccess ) \
    TABLE( errSecUnimplemented ) \
    TABLE( errSecParam ) \
    TABLE( errSecAllocate ) \
    TABLE( errSecNotAvailable ) \
    TABLE( errSecAuthFailed ) \
    TABLE( errSecDuplicateItem ) \
    TABLE( errSecItemNotFound ) \
    TABLE( errSecInteractionNotAllowed ) \
    TABLE( errSecDecode )

// To generate constant names add the prefix: kSecClass
#define TABLE_kSecClass \
    TABLE( Certificate ) \
    TABLE( GenericPassword ) \
    TABLE( Identity ) \
    TABLE( InternetPassword ) \
    TABLE( Key )

// To generate constant names add the prefix: kSecAttr
// Second parameter is the type of the corresponding dictionary entry.
#define TABLE_kSecAttr \
    TABLE( Accessible, CFTypeRef ) \
    TABLE( AccessControl, SecAccessControlRef ) \
    TABLE( Synchronizable, CFBooleanRef ) \
    TABLE( CreationDate, CFDateRef ) \
    TABLE( ModificationDate, CFDateRef ) \
    TABLE( Accessible, CFTypeRef ) \
    TABLE( Description, CFStringRef ) \
    TABLE( Comment, CFStringRef ) \
    TABLE( Creator, CFNumberRef ) \
    TABLE( Type, CFNumberRef ) \
    TABLE( Label, CFStringRef ) \
    TABLE( IsInvisible, CFBooleanRef ) \
    TABLE( IsNegative, CFBooleanRef ) \
    TABLE( Account, CFStringRef ) \
    TABLE( Service, CFStringRef ) \
    TABLE( Generic, CFDataRef ) \
    TABLE( SecurityDomain, CFStringRef ) \
    TABLE( Server, CFStringRef ) \
    TABLE( Protocol, CFNumberRef ) \
    TABLE( AuthenticationType, CFNumberRef ) \
    TABLE( Port, CFNumberRef ) \
    TABLE( Path, CFStringRef ) \
    TABLE( Subject, CFDataRef ) \
    TABLE( Issuer, CFDataRef ) \
    TABLE( SerialNumber, CFDataRef ) \
    TABLE( SubjectKeyID, CFDataRef ) \
    TABLE( PublicKeyHash, CFDataRef ) \
    TABLE( CertificateType, CFNumberRef ) \
    TABLE( CertificateEncoding, CFNumberRef ) \
    TABLE( KeyClass, CFTypeRef ) \
    TABLE( ApplicationLabel, CFStringRef ) \
    TABLE( IsPermanent, CFBooleanRef ) \
    TABLE( ApplicationTag, CFDataRef ) \
    TABLE( KeyType, CFNumberRef ) \
    TABLE( KeySizeInBits, CFNumberRef ) \
    TABLE( EffectiveKeySize, CFNumberRef ) \
    TABLE( CanEncrypt, CFBooleanRef ) \
    TABLE( CanDecrypt, CFBooleanRef ) \
    TABLE( CanDerive, CFBooleanRef ) \
    TABLE( CanSign, CFBooleanRef ) \
    TABLE( CanVerify, CFBooleanRef ) \
    TABLE( CanWrap, CFBooleanRef ) \
    TABLE( CanUnwrap, CFBooleanRef ) \
    TABLE( AccessGroup, CFStringRef )

// To generate constant names, concatenate and add the prefix: kSecAttr
#define TABLE_kSecAttr_VALUE \
    TABLE( Accessible, WhenUnlocked ) \
    TABLE( Accessible, AfterFirstUnlock ) \
    TABLE( Accessible, Always ) \
    TABLE( Accessible, WhenPasscodeSetThisDeviceOnly ) \
    TABLE( Accessible, WhenUnlockedThisDeviceOnly ) \
    TABLE( Accessible, AfterFirstUnlockThisDeviceOnly ) \
    TABLE( Accessible, AlwaysThisDeviceOnly ) \
    TABLE( Protocol, FTP ) \
    TABLE( Protocol, FTPAccount ) \
    TABLE( Protocol, HTTP ) \
    TABLE( Protocol, IRC ) \
    TABLE( Protocol, NNTP ) \
    TABLE( Protocol, POP3 ) \
    TABLE( Protocol, SMTP ) \
    TABLE( Protocol, SOCKS ) \
    TABLE( Protocol, IMAP ) \
    TABLE( Protocol, LDAP ) \
    TABLE( Protocol, AppleTalk ) \
    TABLE( Protocol, AFP ) \
    TABLE( Protocol, Telnet ) \
    TABLE( Protocol, SSH ) \
    TABLE( Protocol, FTPS ) \
    TABLE( Protocol, HTTPS ) \
    TABLE( Protocol, HTTPProxy ) \
    TABLE( Protocol, HTTPSProxy ) \
    TABLE( Protocol, FTPProxy ) \
    TABLE( Protocol, SMB ) \
    TABLE( Protocol, RTSP ) \
    TABLE( Protocol, RTSPProxy ) \
    TABLE( Protocol, DAAP ) \
    TABLE( Protocol, EPPC ) \
    TABLE( Protocol, IPP ) \
    TABLE( Protocol, NNTPS ) \
    TABLE( Protocol, LDAPS ) \
    TABLE( Protocol, TelnetS ) \
    TABLE( Protocol, IMAPS ) \
    TABLE( Protocol, IRCS ) \
    TABLE( Protocol, POP3S ) \
    TABLE( AuthenticationType, NTLM ) \
    TABLE( AuthenticationType, MSN ) \
    TABLE( AuthenticationType, DPA ) \
    TABLE( AuthenticationType, RPA ) \
    TABLE( AuthenticationType, HTTPBasic ) \
    TABLE( AuthenticationType, HTTPDigest ) \
    TABLE( AuthenticationType, HTMLForm ) \
    TABLE( AuthenticationType, Default ) \
    TABLE( KeyClass, Public ) \
    TABLE( KeyClass, Private ) \
    TABLE( KeyClass, Symmetric ) \
    TABLE( KeyType, RSA ) \
    TABLE( KeyType, EC ) \


+(NSString *)dumpConstantSymbols
{
    int secCode[] = {
#define TABLE( KSEC_OSSTATUS ) KSEC_OSSTATUS,
        SEC_OSSTATUS_TABLE
#undef TABLE
        0
    };

    char *secCodeSymbol[] = {
#define TABLE( KSEC_OSSTATUS ) # KSEC_OSSTATUS,
        SEC_OSSTATUS_TABLE
#undef TABLE
        NULL
    };

    CFTypeRef secKey[] = {

#define TABLE( KSEC_CLASS ) kSecClass ## KSEC_CLASS,
        TABLE_kSecClass
#undef TABLE

#define TABLE(KSEC_ATTR, KSEC_DATA_TYPE) kSecAttr ## KSEC_ATTR,
        TABLE_kSecAttr
#undef TABLE

#define TABLE(KSEC_ATTR, KSEC_ATTR_VALUE) \
    kSecAttr ## KSEC_ATTR ## KSEC_ATTR_VALUE,
        TABLE_kSecAttr_VALUE
#undef TABLE
        
        NULL
    };

    char *secKeySymbol[] = {

#define TABLE( KSEC_CLASS ) "kSecClass" # KSEC_CLASS,
        TABLE_kSecClass
#undef TABLE

#define TABLE(KSEC_ATTR, KSEC_DATA_TYPE) "kSecAttr" # KSEC_ATTR,
        TABLE_kSecAttr
#undef TABLE

#define TABLE(KSEC_ATTR, KSEC_ATTR_VALUE) \
    "kSecAttr" # KSEC_ATTR # KSEC_ATTR_VALUE,
        TABLE_kSecAttr_VALUE
#undef TABLE
        
        NULL
    };

    NSMutableString *ret = [NSMutableString stringWithString:@""];

    for (int index=0; secCodeSymbol[index]; index++) {
        [ret appendFormat:
         @"OSStatus %d: %s\n", secCode[index], secCodeSymbol[index] ];
    }
    for (int index=0; secKeySymbol[index]; index++) {
        [ret appendFormat:
         @"\"%@\" %s\n", secKey[index], secKeySymbol[index] ];
    }

    return ret;
}

+(NSString *)symbolForSecAttr:(CFTypeRef)cfTypeRef
{
#define TABLE(KSEC_ATTR, KSEC_DATA_TYPE) kSecAttr ## KSEC_ATTR,
    CFTypeRef secAttrKey[] = {TABLE_kSecAttr NULL };
#undef TABLE
#define TABLE(KSEC_ATTR, KSEC_DATA_TYPE) "kSecAttr" # KSEC_ATTR,
    char *secAttrSymbol[] = { TABLE_kSecAttr NULL };
#undef TABLE
    
    return [KeychainUtility stringFor:cfTypeRef
                             matching:secAttrKey
                                   in:secAttrSymbol];
}

+(NSString *)symbolForSecClass:(CFTypeRef)secClass
{
#define TABLE( KSEC_CLASS ) kSecClass ## KSEC_CLASS,
    CFTypeRef secClassKey[] = { TABLE_kSecClass NULL };
#undef TABLE
#define TABLE( KSEC_CLASS ) "kSecClass" # KSEC_CLASS,
    char *secClassSymbol[] = { TABLE_kSecClass NULL };
#undef TABLE
    return [KeychainUtility stringFor:secClass
                             matching:secClassKey
                                   in:secClassSymbol];
}

+(NSString *)symbolForSecAttr:(CFTypeRef)attribute
                        value:(CFTypeRef)value
{
#define TABLE(KSEC_ATTR, KSEC_ATTR_VALUE) \
    kSecAttr ## KSEC_ATTR ## KSEC_ATTR_VALUE,

    CFTypeRef secAttrValueKey[] = {TABLE_kSecAttr_VALUE NULL };

#undef TABLE

#define TABLE(KSEC_ATTR, KSEC_ATTR_VALUE) kSecAttr ## KSEC_ATTR,
    CFTypeRef prefixes[] = {TABLE_kSecAttr_VALUE NULL };
#undef TABLE

#define TABLE(KSEC_ATTR, KSEC_ATTR_VALUE) \
    "kSecAttr" # KSEC_ATTR # KSEC_ATTR_VALUE,

    char *secAttrValueSymbol[] = { TABLE_kSecAttr_VALUE NULL };

#undef TABLE
    
    return [KeychainUtility stringFor:value
                           withPrefix:attribute
                             matching:secAttrValueKey
                            andPrefix:prefixes
                                   in:secAttrValueSymbol];
}

+(NSString *)stringFor:(CFTypeRef)key
              matching:(CFTypeRef[])keys
                    in:(char *[])map
{
    return [KeychainUtility stringFor:key
                           withPrefix:NULL
                             matching:keys
                            andPrefix:NULL
                                   in:map];
}

+(NSString *)stringFor:(CFTypeRef)key
            withPrefix:(CFTypeRef)prefix
              matching:(CFTypeRef[])keys
             andPrefix:(CFTypeRef[])prefixes
                    in:(char *[])map
{
    for( int index=0; map[index]; index++) {
        if (CFEqual(key, keys[index]) &&
            ( (!prefix) || (!prefixes) || CFEqual(prefix, prefixes[index]) ))
        {
            return [NSString stringWithCString:map[index]
                                      encoding:NSASCIIStringEncoding];
        }
    }
    
    return nil;
}

/** Message for an OSStatus value.
 * There are also Apple command line tools for this. Try either of the
 * following:
 *
 *     security error <security OSStatus>
 *     macerror <any OSStatus>
 */
+(NSString *)messageForOSStatus:(OSStatus)osStatus
{
#define TABLE( KSEC_OSSTATUS ) KSEC_OSSTATUS,
    int secCode[] = { SEC_OSSTATUS_TABLE 0 };
#undef TABLE
    char *secCodeSymbol[] = {
#define TABLE( KSEC_OSSTATUS ) # KSEC_OSSTATUS,
        SEC_OSSTATUS_TABLE
#undef TABLE
        NULL
    };

    // If it matches a listed OSStatus value, return the symbol.
    for( int index=0; secCodeSymbol[index]; index++) {
        if ( secCode[index] == (int)osStatus ) {
            return [NSString stringWithCString:secCodeSymbol[index]
                                      encoding:NSASCIIStringEncoding];
        }
    }
    
    // Otherwise, create a numeric and string representation.
    
    // The following code isn't needed for OSStatus values relating to security.
    // It's handy to have around though, for audio error codes for example.
    char *osStatusChars = (char *)&osStatus;
    char osStatusArray[sizeof(OSStatus) + 1];
    for (int index; index < sizeof(OSStatus); index++) {
        osStatusArray[sizeof(OSStatus) - (index+1)] = *(osStatusChars + index);
    }
    osStatusArray[sizeof(OSStatus)] = 0;

    return [NSString stringWithFormat:
            @"%d \"%s\"", (int)osStatus, osStatusArray];
}

+(NSString *)keychainDump
{
#define TABLE( KSEC_CLASS ) kSecClass ## KSEC_CLASS,
    CFTypeRef secClassValues[] = { TABLE_kSecClass NULL };
#undef TABLE

    NSMutableString *ret = [NSMutableString stringWithString:@""];
    NSUInteger runningTotal = 0;

    for (int classIndex=0; secClassValues[classIndex]; classIndex++) {
        [ret appendString:
         [KeychainUtility keychainDumpClass:secClassValues[classIndex]
                               runningTotal:&runningTotal]];
        
    }
    [ret appendFormat:@"Total items: %lu.\n", (unsigned long)runningTotal];
    
    return ret;
}

+(NSString *)keychainDumpClass:(CFTypeRef)secClass
                  runningTotal:(NSUInteger *)runningTotal
{
    NSMutableString *ret = [NSMutableString stringWithString:@""];

    NSString *className = [KeychainUtility symbolForSecClass:secClass];

    NSDictionary *query =
    @{(__bridge id)kSecClass: (__bridge id)secClass,
      (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitAll,
      (__bridge id)kSecReturnAttributes: @YES,
      (__bridge id)kSecAttrSynchronizable:
          (__bridge id)kSecAttrSynchronizableAny };
    
    CFTypeRef result;
    OSStatus osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query,
                                            &result);
    if (osStatus == errSecSuccess) {
        if (runningTotal) {
            (*runningTotal) +=  CFArrayGetCount((CFArrayRef)result);
        }
        [ret appendString:
         [KeychainUtility KeychainDumpContents:(CFArrayRef)result
                                  forClassName:className]];
    }
    else if (osStatus == errSecItemNotFound) {
        [ret appendFormat:@"%@ empty.\n", className];
    }
    else {
        [ret appendFormat:@"%@ error: %@.\n",
         className, [KeychainUtility messageForOSStatus:osStatus]];
    }
    
    return ret;
}

+(NSString *)KeychainDumpContents:(CFArrayRef)contents
                     forClassName:(NSString *)className
{
    long resultCount = CFArrayGetCount(contents);

    NSMutableString *ret = [NSMutableString stringWithFormat:
                            @"%@ items %ld:\n", className, resultCount];
    for (int arrayIndex=0; arrayIndex < resultCount; arrayIndex++) {
        CFDictionaryRef dictionary =
        (CFDictionaryRef) CFArrayGetValueAtIndex(contents, arrayIndex);
        
        CFIndex attributeCount = CFDictionaryGetCount(dictionary);
        [ret appendFormat:@"%@[%d] attributes %ld:\n",
         className, arrayIndex, attributeCount];
        void **keys;
        void **values;
        keys = malloc( (sizeof keys[0]) * attributeCount);
        values = malloc( (sizeof values[0]) * attributeCount);
        CFDictionaryGetKeysAndValues(dictionary,
                                     (const void **)keys,
                                     (const void **)values);
        for (int attributeIndex=0;
             attributeIndex < attributeCount;
             attributeIndex++ )
        {
            CFTypeRef key = (CFTypeRef)keys[attributeIndex];
            [ret appendFormat:@"%2d \"%@\" %@ %@\n",
             attributeIndex + 1, key,
             [KeychainUtility symbolForSecAttr:key],
             [KeychainUtility value:(CFDataRef)(values[attributeIndex])
                          asSecAttr:key]];
        }
        free(keys);
        free(values);
    }

    return ret;
}

+(NSString *)secAttrValue_CFDateRef:(CFDateRef)cfDateRef
                       forAttribute:(CFTypeRef)attribute
{
    CFDateFormatterRef formatter =
    CFDateFormatterCreate(NULL,
                          NULL,
                          kCFDateFormatterShortStyle,
                          kCFDateFormatterMediumStyle);
    return (__bridge NSString *)CFDateFormatterCreateStringWithDate(NULL,
                                                                    formatter,
                                                                    cfDateRef);
}
+(NSString *)secAttrValue_CFTypeRef:(CFTypeRef)cfTypeRef
                       forAttribute:(CFTypeRef)attribute
{
    return [NSString stringWithFormat:@"\"%@\" %@",
            cfTypeRef, [KeychainUtility symbolForSecAttr:attribute
                                                   value:cfTypeRef]];
}
+(NSString *)secAttrValue_CFStringRef:(CFStringRef)cfStringRef
                         forAttribute:(CFTypeRef)attribute
{
    return [NSString stringWithFormat:
            @"\"%@\"", (__bridge NSString *)(cfStringRef)];
}
+(NSString *)secAttrValue_CFNumberRef:(CFNumberRef)cfNumberRef
                         forAttribute:(CFTypeRef)attribute
{
    return [NSString stringWithFormat:@"%@", cfNumberRef];
}
+(NSString *)secAttrValue_CFBooleanRef:(CFBooleanRef)cfBooleanRef
                          forAttribute:(CFTypeRef)attribute
{
    return cfBooleanRef == kCFBooleanTrue ? @"YES" : @"NO";
}
+(NSString *)secAttrValue_CFDataRef:(CFDataRef)cfDataRef
                       forAttribute:(CFTypeRef)attribute
{
    return [KeychainUtility dumpCFData:cfDataRef];
}
+(NSString *)
secAttrValue_SecAccessControlRef:(SecAccessControlRef)secAccessControlRef
                    forAttribute:(CFTypeRef)attribute
{
    return @"ToDo: SecAccessControl dump goes here.";
}

+(NSString *)value:(CFDataRef)value
            asSecAttr:(CFTypeRef)attribute
{
    NSString *ret = nil;
#define TABLE(KSEC_ATTR, KSEC_DATA_TYPE) \
    if (CFEqual( attribute, kSecAttr ## KSEC_ATTR )) { \
        ret = [KeychainUtility \
               secAttrValue_ ## KSEC_DATA_TYPE :(KSEC_DATA_TYPE)value \
               forAttribute: kSecAttr ## KSEC_ATTR ]; \
    }

    TABLE_kSecAttr
#undef TABLE

    return ret;
}

/** Dump a CFData object in a generic way.
 * The dump consists of:
 * -   The size in bytes, and only that if it's zero.
 * -   Sequence of characters in "" if all the data is printable.
 * -   Seuquence of characters and hex codes in () is any of the data was not
 *     printable.
 */
+(NSString *)dumpCFData:(CFDataRef)cfDataRef
{
    NSUInteger size = CFDataGetLength(cfDataRef);
    
    if (size == 0) {
        return @"0 bytes.";
    }

    const UInt8 *start = CFDataGetBytePtr(cfDataRef);

    // Check if it happens to be all printable.
    BOOL allPrint = YES;
    for (int index=0; index < size; index++) {
        char value = *(start + index);
        if (!isprint(value)) {
            allPrint = NO;
            break;
        }
    }
    
    NSMutableString *ret = [NSMutableString stringWithFormat:
                            @"%ld bytes %@", (unsigned long)size,
                            allPrint ? @"\"" : @"(" ];
    
    for (int index=0; index < size; index++) {
        if ( (!allPrint) && index > 0) {
            [ret appendString:@" "];
        }
        char value = *(start + index);
        if (isprint(value)) {
            [ret appendFormat:@"%c", value];
        }
        else {
            [ret appendFormat:@"%02X", value];
        }
    }
    
    [ret appendString: allPrint ? @"\"" : @")"];

    return ret;
}

+(BOOL)keychainErase:(NSString **)errorMessage
{
#define TABLE( KSEC_CLASS ) kSecClass ## KSEC_CLASS,
    CFTypeRef secClassValues[] = { TABLE_kSecClass NULL };
#undef TABLE
    
    NSMutableString *ret = [NSMutableString stringWithString:@""];
    
    BOOL ok = YES;
    
    for (int classIndex=0; secClassValues[classIndex]; classIndex++) {
        NSString *classErrorMessage;
        if (![KeychainUtility keychainEraseClass:secClassValues[classIndex]
                                    errorMessage:&classErrorMessage])
        {
            [ret appendFormat:
             @"%@ erase failed. %@.\n",
             [KeychainUtility symbolForSecClass:secClassValues[classIndex]],
             classErrorMessage];
            ok = NO;
        }
    }
    
    if (ok) {
        ret = nil;
    }
    
    *errorMessage = ret;
    
    return ok;
}
+(BOOL)keychainEraseClass:(CFTypeRef)secClass
             errorMessage:(NSString **)errorMessage
{
    NSDictionary *query = @{(__bridge id)kSecClass: (__bridge id)secClass};
    
    for (;;) {
        OSStatus osStatus = SecItemDelete((__bridge CFDictionaryRef)query);
        
        if (osStatus == errSecSuccess) {
            // Something was erased. Go around again.
            continue;
        }
        
        if (osStatus == errSecItemNotFound) {
            // Nothing to erase. We're done.
            *errorMessage = nil;
            return YES;
        }
        else {
            // Something went wrong. Fail.
            *errorMessage = [KeychainUtility messageForOSStatus:osStatus];
            return NO;
        }
    }
}

@end
