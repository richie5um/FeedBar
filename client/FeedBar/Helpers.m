//
//  Helpers.m
//  fflickit
//
//  Created by Rich Somerfield on 10/9/11.
//  Copyright 2013 Rich Somerfield. All rights reserved.
//

#import <IOKit/IOKitLib.h>
#import "Helpers.h"

@implementation Helpers

/////////////////////////////////////////////////////////////////////
+ (void)showIconInDock:(BOOL)showIconInDock {
    
    ProcessSerialNumber psn = { 0, kCurrentProcess };    
    if (YES == showIconInDock) {
        
        TransformProcessType(&psn, kProcessTransformToForegroundApplication);
    } else {
        
        TransformProcessType(&psn, kProcessTransformToUIElementApplication);
    }    
}

/////////////////////////////////////////////////////////////////////
// MIT license
+ (BOOL)isLaunchAtStartup {
    
    // See if the app is currently in LoginItems.
    LSSharedFileListItemRef itemRef = [Helpers itemRefInLoginItems];
    
    // Store away that boolean.
    BOOL isInList = itemRef != nil;
    
    // Release the reference if it exists.
    if (itemRef != nil) CFRelease(itemRef);
    
    return isInList;
}

/////////////////////////////////////////////////////////////////////
+ (void)toggleLaunchAtStartup {
    
    // Toggle the state.
    BOOL shouldBeToggled = ![Helpers isLaunchAtStartup];
    
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if ( nil == loginItemsRef ) {
        return; 
    }
    
    if (shouldBeToggled) {
        
        // Add the app to the LoginItems list.
        CFURLRef appUrl = (__bridge_retained CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        if ( nil != appUrl ) {
            LSSharedFileListItemRef itemRef = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, NULL, NULL, appUrl, NULL, NULL);
            if ( nil != itemRef ) {
                
                CFRelease(itemRef);   
            }
            CFRelease(appUrl);
        }
    } else {
        
        // Remove the app from the LoginItems list.
        LSSharedFileListItemRef itemRef = [Helpers itemRefInLoginItems];
        LSSharedFileListItemRemove(loginItemsRef,itemRef);
        if (itemRef != nil) {
            CFRelease(itemRef);
        }
    }
    CFRelease(loginItemsRef);
}

/////////////////////////////////////////////////////////////////////
+ (LSSharedFileListItemRef)itemRefInLoginItems {
    
    LSSharedFileListItemRef itemRef = nil;
    NSURL *itemUrl = nil;
    
    // Get the app's URL.
    NSURL *appUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    
    // Get the LoginItems list.
    LSSharedFileListRef loginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItemsRef == nil) return nil;
    
    // Iterate over the LoginItems.
    NSArray *loginItems = (__bridge_transfer NSArray *)LSSharedFileListCopySnapshot(loginItemsRef, nil);
    for (int currentIndex = 0; currentIndex < [loginItems count]; currentIndex++) {
        // Get the current LoginItem and resolve its URL.
        LSSharedFileListItemRef currentItemRef = (__bridge_retained LSSharedFileListItemRef)[loginItems objectAtIndex:currentIndex];
        
        CFURLRef cfurl = (__bridge CFURLRef)itemUrl;
        if (LSSharedFileListItemResolve(currentItemRef, 0, &cfurl, NULL) == noErr) {
            // Compare the URLs for the current LoginItem and the app.
            if ([itemUrl isEqual:appUrl]) {
                // Save the LoginItem reference.
                itemRef = currentItemRef;
            }
        }
    }
    
    // Retain the LoginItem reference.
    if (itemRef != nil) CFRetain(itemRef);
    
    // Release the LoginItems lists.
    CFRelease(loginItemsRef);
    
    return itemRef;
}

///////////////////////////////////////////////////////////////////////////////
+(NSString*)createGUID {
    
    // Create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the string representation of the UUID
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    
    return uuidString;
}

///////////////////////////////////////////////////////////////////////////////
+(NSString*)createSafeFileStringFromFile:(NSString*)file {
    
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@":/"];
    return [[file componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@"."];
}

///////////////////////////////////////////////////////////////////////////////
+ (NSString*)utcFromDate:(NSDate*)date {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    NSString *dateString = [dateFormatter stringFromDate:date];
    return dateString;
}

/////////////////////////////////////////////////////////////////////
+ (NSString*)serialNumber {
    
    io_service_t platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice"));
    CFStringRef serialNumberAsCFString = NULL;
    
    if (platformExpert) {
        
        serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
                                                                 CFSTR(kIOPlatformSerialNumberKey),
                                                                 kCFAllocatorDefault, 0);
        IOObjectRelease(platformExpert);
    }
    
    NSString *serialNumberAsNSString = nil;
    if (serialNumberAsCFString) {
        
        serialNumberAsNSString = [NSString stringWithString:(__bridge NSString *)serialNumberAsCFString];
        CFRelease(serialNumberAsCFString);
    }
    
    return serialNumberAsNSString;
}

///////////////////////////////////////////////////////////////////////////////
+(NSString*)deviceName {
    
    NSString* deviceName = (__bridge_transfer NSString*)CSCopyMachineName();
    
    return deviceName;
}

///////////////////////////////////////////////////////////////////////////////
+(NSString*)devicePlatformDescription {
    
    return [NSString stringWithFormat:@"Model:%@ OS:%@", [Helpers deviceModel], [Helpers platformVersion]];
}

/////////////////////////////////////////////////////////////////////
+(NSString*)platformVersion {
    
    SInt32 versionMajor = 0;
    SInt32 versionMinor = 0;
    SInt32 versionBugFix = 0;
    
    Gestalt( gestaltSystemVersionMajor, &versionMajor );
    Gestalt( gestaltSystemVersionMinor, &versionMinor );
    Gestalt( gestaltSystemVersionBugFix, &versionBugFix );
    
    return [NSString stringWithFormat:@"%d.%d.%d", versionMajor, versionMinor, versionBugFix];
}

///////////////////////////////////////////////////////////////////////////////
+(NSString*)deviceModel
{
    static NSString *computerModel = nil;
    
    if (!computerModel) {
        
        io_service_t pexpdev;
        if ((pexpdev = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("IOPlatformExpertDevice")))) {
            
            NSData *data;
            if ((data = (__bridge_transfer id)IORegistryEntryCreateCFProperty(pexpdev, CFSTR("model"), kCFAllocatorDefault, 0))) {
                
                computerModel = [[NSString allocWithZone:NULL]
                                 initWithCString:[data bytes] encoding:NSASCIIStringEncoding];
            }
        }
    }
    
    return computerModel;
}

////////////////////////////////////////////////////////////////////////////////////
+(NSMutableDictionary*)dictionaryFromString:(NSString*)string {
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    
    NSArray *splitArray = [string componentsSeparatedByString:@"&"];
    for( NSString* keyValueString in splitArray ) {
        
        NSArray *splitKeyValue = [keyValueString componentsSeparatedByString:@"="];
        if ( 3 == [splitKeyValue count] ) {
            
            NSString* keyString = [Helpers hashDecodeString:[splitKeyValue objectAtIndex:0]];
            NSString* valueType = [Helpers hashDecodeString:[splitKeyValue objectAtIndex:1]];
            NSString* valueString = [Helpers hashDecodeString:[splitKeyValue objectAtIndex:2]];
            
            if ( nil != keyString && 0 < [keyString length] && nil != valueString ) {
                
                id value;
                
                if ( [valueType isEqualToString:@"S"] ) {
                    value = valueString;
                } else if ( [valueType isEqualToString:@"D"] ) {
                    value = [Helpers dictionaryFromString:valueString];
                } else if ( [valueType isEqualToString:@"A"] ) {
                    value = [Helpers arrayFromString:valueString];
                }
                
                if ( nil != value ) {
                    [dictionary setObject:value forKey:keyString];
                }
            }
        }
    }
    
    return dictionary;
}

////////////////////////////////////////////////////////////////////////////////////
+(NSString*)stringFromDictionary:(NSDictionary*)dictionary {
    
    NSMutableArray* parametersArray = [[NSMutableArray alloc] init];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSString* keyString = key;
        NSString* valueString;
        NSString* valueType;
        
        if ( [obj isKindOfClass:[NSString class]]) {
            valueString = obj;
            valueType = @"S";
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary* valueDictionary = obj;
            valueString = [Helpers stringFromDictionary:valueDictionary];
            valueType = @"D";
        } else if ( [obj isKindOfClass:[NSArray class]]) {
            NSArray* valueArray = obj;
            valueString = [Helpers stringFromArray:valueArray];
            valueType = @"A";
        }
        
        [parametersArray addObject:[NSString stringWithFormat:@"%@=%@=%@",
                                    [Helpers hashEncodeString:keyString fromSet:@"&="],
                                    valueType,
                                    [Helpers hashEncodeString:valueString fromSet:@"&="]]];
    }];
    NSString* parameterString = [parametersArray componentsJoinedByString:@"&"];
    
    return parameterString;
}

////////////////////////////////////////////////////////////////////////////////////
+(NSString*)stringFromArray:(NSArray*)array {
    
    NSMutableArray* parametersArray = [[NSMutableArray alloc] init];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop){

        NSString* valueString;
        NSString* valueType;
        
        if ( [obj isKindOfClass:[NSString class]]) {
            valueString = obj;
            valueType = @"S";
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            NSDictionary* valueDictionary = obj;
            valueString = [Helpers stringFromDictionary:valueDictionary];
            valueType = @"D";
        } else if ( [obj isKindOfClass:[NSArray class]]) {
            NSArray* valueArray = obj;
            valueString = [Helpers stringFromArray:valueArray];
            valueType = @"A";
        }
        
        [parametersArray addObject:[NSString stringWithFormat:@"%@=%@",
                                    valueType,
                                    [Helpers hashEncodeString:valueString fromSet:@"&="]]];
    }];
    NSString* parameterString = [parametersArray componentsJoinedByString:@"&"];
    
    return parameterString;
}

////////////////////////////////////////////////////////////////////////////////////
+(NSArray*)arrayFromString:(NSString*)string {
    
    NSMutableArray* array = [NSMutableArray array];
    
    NSArray *splitArray = [string componentsSeparatedByString:@"&"];
    for( NSString* typeValueString in splitArray ) {
        
        NSArray *splitTypeValue = [typeValueString componentsSeparatedByString:@"="];
        if ( 2 == [splitTypeValue count] ) {
            
            NSString* valueType = [Helpers hashDecodeString:[splitTypeValue objectAtIndex:0]];
            NSString* valueString = [Helpers hashDecodeString:[splitTypeValue objectAtIndex:1]];
            
            if ( nil != valueString ) {
                
                id value;
                
                if ( [valueType isEqualToString:@"S"] ) {
                    value = valueString;
                } else if ( [valueType isEqualToString:@"D"] ) {
                    value = [Helpers dictionaryFromString:valueString];
                } else if ( [valueType isEqualToString:@"A"] ) {
                    value = [Helpers arrayFromString:valueString];
                }
                
                if ( nil != value ) {
                    [array addObject:value];
                }
            }
        }
    }
    
    return array;
}

////////////////////////////////////////////////////////////////////////////////////
+(NSString*)hashEncodeString:(NSString*)string fromSet:(NSString*)set {
    
    NSString* dataString = string;
    
    // We use '#' as an escape char, so we have to escape it too (make sure we remove any other '#' from the list].
    set = [@"#" stringByAppendingString:[set stringByReplacingOccurrencesOfString:@"#" withString:@""]];
    
    NSUInteger setLength = [set length];
    
    for ( NSUInteger index = 0; index < setLength; ++index ) {
        
        // Get each character at a time from the set
        NSRange range = NSMakeRange(index, 1);
        NSString* character = [set substringWithRange:range];
        
        NSString* characterHex = @"#";
        unichar setChar = [set characterAtIndex:index];
        characterHex = [characterHex stringByAppendingFormat:@"%03x", setChar];
        
        // Replace our set character with its encoded string
        dataString = [dataString stringByReplacingOccurrencesOfString:character withString:characterHex];
    }
    
    return dataString;
}

////////////////////////////////////////////////////////////////////////////////////
+(NSString*)hashDecodeString:(NSString*)string {
    
    NSString *dataString = string;
    do {
        // Check if it contains our escape char
        NSRange range = [dataString rangeOfString:@"#" options:NSRegularExpressionSearch];
        if (NSNotFound == range.location) {
            break;
        }
        
        NSString *characterHex = [dataString substringWithRange:NSMakeRange(range.location + 1, 3)];
        
        // Get the string character from the Decimal
        unsigned decimal = 0;
        NSScanner *scanner = [NSScanner scannerWithString:characterHex];
        [scanner scanHexInt:&decimal];
        
        unichar setChar = decimal;
        NSString *character = [NSString stringWithFormat:@"%C", setChar];
        
        // Now add our prefix
        characterHex = [@"#" stringByAppendingString:characterHex];
        
        // Do the work
        dataString = [dataString stringByReplacingOccurrencesOfString:characterHex withString:character];
    } while (TRUE); //*** Loop until we hit the NSNotFound
    
    return dataString;
}


@end
