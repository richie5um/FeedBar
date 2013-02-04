//
//  NSDate+RFC3339.m
//  Astro
//
//  Created by Paul Branton on 05/03/2012.
//  Copyright (c) 2012 AppSense. All rights reserved.
//

#import "NSDate+InternationalStandards.h"

@implementation NSDate (InternationalStandards)
static NSDateFormatter *    sRFC3339DateFormatter;
static NSDateFormatter *    sHumanReadableDateFormatter;
static NSDateFormatter *    sHumanShortReadableDateFormatter;
static NSDateFormatter *    sISO8601DateFormatter;

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
        
        sHumanReadableDateFormatter = [[NSDateFormatter alloc] init];
        assert(sHumanReadableDateFormatter != nil);
        
        [sHumanReadableDateFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        [sHumanReadableDateFormatter setDateStyle:NSDateFormatterMediumStyle];
         [sHumanReadableDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    }
    
    NSString* humanReadableString = [sHumanReadableDateFormatter stringFromDate:(NSDate*)self];
    
    return humanReadableString;    
}

-(NSString*)humanShortReadableString{
    // If the date formatter isn't already set up, do that now and cache them 
    // for subsequence reuse.
    
    if (sHumanShortReadableDateFormatter == nil) {

        sHumanShortReadableDateFormatter = [[NSDateFormatter alloc] init];
        assert(sHumanShortReadableDateFormatter != nil);
        
        [sHumanShortReadableDateFormatter setLocale:[NSLocale autoupdatingCurrentLocale]];
        [sHumanShortReadableDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [sHumanShortReadableDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    NSString* humanReadableString = [sHumanShortReadableDateFormatter stringFromDate:(NSDate*)self ];
    
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

+(NSDate*)dateFromISO8601:(NSString*)value_{
    NSString *dateString = [value_ substringToIndex:14];
    
    if (sISO8601DateFormatter == nil) {
        NSLocale *enUSPOSIXLocale;
        
        sISO8601DateFormatter = [[NSDateFormatter alloc] init];
        assert(sISO8601DateFormatter != nil);
        
        enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] ;
        assert(enUSPOSIXLocale != nil);
        
        [sISO8601DateFormatter setLocale:enUSPOSIXLocale];
        [sISO8601DateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        [sISO8601DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }
    NSDate *date = [sISO8601DateFormatter dateFromString:dateString];
    return date;
}


@end
