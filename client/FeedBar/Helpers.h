//
//  Helpers.h
//  ASDataCollector
//
//  Created by Rich Somerfield on 01/01/13.
//  Copyright 2013 AppSense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Helpers : NSObject {
@private
    
}

+(void)showIconInDock:(BOOL)showIconInDock;

+(BOOL)isLaunchAtStartup;
+(void)toggleLaunchAtStartup;
+(LSSharedFileListItemRef)itemRefInLoginItems;

+(NSString*)createGUID;

+(NSString*)createSafeFileStringFromFile:(NSString*)file;

+(NSString*)utcFromDate:(NSDate*)date;

+(NSString*)serialNumber;
+(NSString*)platformVersion;
+(NSString*)devicePlatformDescription;
+(NSString*)deviceModel;
+(NSString*)deviceName;

+(NSMutableDictionary*)dictionaryFromString:(NSString*)string;
+(NSString*)stringFromDictionary:(NSDictionary*)dictionary;
+(NSString*)stringFromArray:(NSArray*)array;
+(NSArray*)arrayFromString:(NSString*)string;
+(NSString*)hashEncodeString:(NSString*)string fromSet:(NSString*)set;
+(NSString*)hashDecodeString:(NSString*)string;

@end
