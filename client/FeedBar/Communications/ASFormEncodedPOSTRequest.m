/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  NSMutableURLRequest+ASAdditions.m
//  BasicHTTPPost
//
//  Created by Matt Drance on 9/20/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import "ASFormEncodedPOSTRequest.h"
#import "NSString+ASURLAdditions.h"

@implementation ASFormEncodedPOSTRequest

/////////////////////////////////////////////////////////////////////////////////////
+ (id)requestWithURL:(NSURL *)url formParameters:(NSDictionary *)params {
    
    return [[self alloc] initWithURL:url formParameters:params];
}

/////////////////////////////////////////////////////////////////////////////////////
- (id)initWithURL:(NSURL *)url formParameters:(NSDictionary *)params {
    
    if ((self = [super initWithURL:url])) {
        
        [self setHTTPMethod:@"POST"];
        [self setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"]; 
        [self setFormParameters:params];        
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////////////
- (void)setFormParameters:(NSDictionary *)params {
    
    NSStringEncoding enc = NSUTF8StringEncoding;
    NSMutableString *postBody = [NSMutableString string];
    for (NSString *paramKey in params) {
        
        if ([paramKey length] > 0) {
            
            NSString *value = [params objectForKey:paramKey];
            NSString *encodedValue = [value ASURLEncodedFormStringUsingEncoding:enc];
            NSUInteger length = [postBody length];
            NSString *paramFormat = (length == 0 ? @"%@=%@" : @"&%@=%@");
            [postBody appendFormat:paramFormat, paramKey, encodedValue];            
        }
    }
    
    NSLog(@"postBody is now %@", postBody);
    [self setHTTPBody:[postBody dataUsingEncoding:enc]];
}

@end
