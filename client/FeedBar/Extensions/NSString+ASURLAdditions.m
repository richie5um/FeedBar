/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  NSString+ASURLAdditions.m
//  MultipartHTTPPost
//
//  Created by Matt Drance on 9/24/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import "NSString+ASURLAdditions.h"

@implementation NSString (ASURLAdditions) 

- (NSString *)ASURLEncodedFormStringUsingEncoding:(NSStringEncoding)enc {
    NSString *escapedStringWithSpaces = 
    [self ASPercentEscapedStringWithEncoding:enc
                                   additionalCharacters:@"&=+"
                                      ignoredCharacters:nil];
    return escapedStringWithSpaces;
}

//
// All illegals are ";/?:@&=$+{}<>," however we only need to escape ";&=+"
- (NSString *)ASRFC3875EncodedString{
    NSString *escapedStringWithSpaces =
    [self ASPercentEscapedStringWithEncoding:NSUTF8StringEncoding
                        additionalCharacters:@";&=+"
                           ignoredCharacters:nil];
    return escapedStringWithSpaces;
}

- (NSString *)ASPercentEscapedStringWithEncoding:(NSStringEncoding)enc
                              additionalCharacters:(NSString *)add
                                 ignoredCharacters:(NSString *)ignore {
    CFStringEncoding convertedEncoding = 
        CFStringConvertNSStringEncodingToEncoding(enc);
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                        kCFAllocatorDefault,
                                                        (__bridge CFStringRef)self,
                                                        (__bridge CFStringRef)ignore,
                                                        (__bridge CFStringRef)add,
                                                        convertedEncoding);
}

@end
