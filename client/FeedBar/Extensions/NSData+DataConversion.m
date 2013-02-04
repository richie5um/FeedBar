//
//  NSData+DataConversion.m
//  Astro
//
//  Created by Rich Somerfield on 17/04/2012.
//  Copyright (c) 2012 AppSense. All rights reserved.
//

#import "NSData+DataConversion.h"

@implementation NSData (DataConversion)

/////////////////////////////////////////////////////////////////////////////////////
-(NSString*)dataString {
    
    return [self dataStringWithEncoding:NSUTF8StringEncoding];
}

/////////////////////////////////////////////////////////////////////////////////////
-(NSString*)dataStringWithEncoding:(NSStringEncoding)encoding {
    
    return [[NSString alloc] initWithData:self encoding:encoding];
}

#if TARGET_OS_IPHONE
/////////////////////////////////////////////////////////////////////////////////////
-(UIImage*)dataImage {
    
    return [UIImage imageWithData:self];
}
#elif TARGET_OS_MAC
/////////////////////////////////////////////////////////////////////////////////////
-(NSImage*)dataImage {
    
    return [[NSImage alloc] initWithData:self];
}

/////////////////////////////////////////////////////////////////////////////////////
-(NSXMLDocument*)dataXML {
    
    return [[NSXMLDocument alloc] initWithData:self options:0 error:nil];
}
#endif

/////////////////////////////////////////////////////////////////////////////////////
-(id)dataJSON {
    
    if([NSJSONSerialization class]) {
        
        if(self == nil) {
            
            return nil;
        } else {
        
            NSError *error = nil;
            
            id returnValue = [NSJSONSerialization JSONObjectWithData:self options:0 error:&error];    
            if(error) {
                
                NSLog(@"JSON Parsing Error: %@", error);
            }
            return returnValue;
        }
    } else {
        
        NSLog(@"No valid JSON Serializers found");
        return [self dataString];
    }
}

@end
