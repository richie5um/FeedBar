//
//  NSDictionary+JSON.m
//  Astro
//
//  Created by Rich Somerfield on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (NSDictionaryJSON)

/////////////////////////////////////////////////////////////////////////////////////
-(NSString*)jsonString {
    
    NSString *jsonString = nil;
    
    if([NSJSONSerialization class]) {
        
        if(self != nil) {
            
            NSError *error = nil;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:&error];
            
            if (nil == error && jsonData) {
                jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        }
    }
    
    return jsonString;
}

@end
