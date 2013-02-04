/***
 * Excerpted from "iOS Recipes",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/cdirec for more book information.
***/
//
//  NSMutableURLRequest+ASAdditions.h
//  BasicHTTPPost
//
//  Created by Matt Drance on 9/20/10.
//  Copyright 2010 Bookhouse Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASFormEncodedPOSTRequest : NSMutableURLRequest {}

+ (id)requestWithURL:(NSURL *)url formParameters:(NSDictionary *)params;
- (id)initWithURL:(NSURL *)url formParameters:(NSDictionary *)params;

- (void)setFormParameters:(NSDictionary *)params;

@end
