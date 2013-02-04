//
//  NSDate+RFC3339.h
//  Astro
//
//  Created by Paul Branton on 05/03/2012.
//  Copyright (c) 2012 AppSense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (RFC3339)

+(NSDate*)dateFromRFC3399:(NSString*)value_;

-(NSString*)rfc3339String;

-(NSString*)humanReadableString;

@end
