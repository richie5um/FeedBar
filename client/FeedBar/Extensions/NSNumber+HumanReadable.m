//
//  NSNumber+HumanReadable.m
//  Astro
//
//  Created by Paul Branton on 06/03/2012.
//  Copyright (c) 2012 AppSense. All rights reserved.
//

#import "NSNumber+HumanReadable.h"

@implementation NSNumber (HumanReadable)

- (NSString *)humanReadableBase10 {
    
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:1];
    
    NSString *formattedString = nil;
    uint64_t size = [self unsignedLongLongValue];
    if (size < 1024) {
        NSString *formattedNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:size]];
        formattedString = [NSString stringWithFormat:@"%@ B", formattedNumber];
    }
    else if (size < 1024 * 1024) {
        NSString *formattedNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:size / 1024.0]];
        formattedString = [NSString stringWithFormat:@"%@ KB", formattedNumber];
    }
    else if (size < 1024 * 1024 * 1024) {
        NSString *formattedNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:size / 1024.0 / 1024.0]];
        formattedString = [NSString stringWithFormat:@"%@ MB", formattedNumber];
    }
    else {
        NSString *formattedNumber = [formatter stringFromNumber:[NSNumber numberWithFloat:size / 1024.0 / 1024.0 / 1024.0]];
        formattedString = [NSString stringWithFormat:@"%@ GB", formattedNumber];
    }
    
    
    return formattedString;
}
@end
