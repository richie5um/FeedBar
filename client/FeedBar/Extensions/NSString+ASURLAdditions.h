/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  NSString+ASFormAdditions.h
//  MultipartHTTPPost
//
//  Created by Matt Drance on 9/24/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (ASURLAdditions) 

- (NSString *)ASURLEncodedFormStringUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)ASRFC3875EncodedString;
- (NSString *)ASPercentEscapedStringWithEncoding:(NSStringEncoding)encoding additionalCharacters:(NSString *)add ignoredCharacters:(NSString *)ignoredCharacters;

@end