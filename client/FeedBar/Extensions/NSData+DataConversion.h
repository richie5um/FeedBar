//
//  NSData+DataConversion.h
//  Astro
//
//  Created by Rich Somerfield on 17/04/2012.
//  Copyright (c) 2012 AppSense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DataConversion)

-(NSString*)dataString;
-(NSString*)dataStringWithEncoding:(NSStringEncoding)encoding;

#if TARGET_OS_IPHONE
-(UIImage*)dataImage;
#elif TARGET_OS_MAC
-(NSImage*)dataImage;
-(NSXMLDocument*)dataXML;
#endif

-(id)dataJSON;

@end


