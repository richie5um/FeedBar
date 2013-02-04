//
//  NSDate+RFC3339.m
//  Astro
//
//  Created by Paul Branton on 05/03/2012.
//  Copyright (c) 2012 AppSense. All rights reserved.
//

#import "NSDate+RFC3339.h"

@implementation NSDate (RFC3339)
static NSDateFormatter *    sRFC3339DateFormatter;
static NSDateFormatter *    sHumanReadableDateFormatter;

-(NSString*)rfc3339String{
    // If the date formatter isn't already set up, do that now and cache them 
    // for subsequence reuse.
    
    if (sRFC3339DateFormatter == nil) {
        NSLocale *enUSPOSIXLocale;
        
        sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
        assert(sRFC3339DateFormatter != nil);
        
        enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] ;
        assert(enUSPOSIXLocale != nil);
        
        [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
        [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    NSString *rfc3339String = [sRFC3339DateFormatter stringFromDate:(NSDate*)self ];

    return rfc3339String;
    
}

-(NSString*)humanReadableString{
    // If the date formatter isn't already set up, do that now and cache them 
    // for subsequence reuse.
    
    if (sHumanReadableDateFormatter == nil) {
        NSLocale *enUSPOSIXLocale;
        
        sHumanReadableDateFormatter = [[NSDateFormatter alloc] init];
        assert(sHumanReadableDateFormatter != nil);
        
        enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] ;
        assert(enUSPOSIXLocale != nil);
        
        [sHumanReadableDateFormatter setLocale:enUSPOSIXLocale];
        [sHumanReadableDateFormatter setDateStyle:NSDateFormatterMediumStyle];
         [sHumanReadableDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        //[sHumanReadableDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    
    NSString* humanReadableString = [sHumanReadableDateFormatter stringFromDate:(NSDate*)self ];
    
    return humanReadableString;    
}


//
// Input could be like this:
//  "2010-08-08T16:15:07+0000"
//   01234567890123456789
// So we truncate at position 19

+(NSDate*)dateFromRFC3399:(NSString*)value_{
    NSString *dateString = [NSString stringWithFormat:@"%@Z",[value_ substringToIndex:19]];
    
    if (sRFC3339DateFormatter == nil) {
        NSLocale *enUSPOSIXLocale;
        
        sRFC3339DateFormatter = [[NSDateFormatter alloc] init];
        assert(sRFC3339DateFormatter != nil);
        
        enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] ;
        assert(enUSPOSIXLocale != nil);
        
        [sRFC3339DateFormatter setLocale:enUSPOSIXLocale];
        [sRFC3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
        [sRFC3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    NSDate *date = [sRFC3339DateFormatter dateFromString:dateString];
    return date;
}


@end
