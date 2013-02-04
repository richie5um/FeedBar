//
//  NSString+Hex.h
//  DataLocker
//
//  Created by Rich Somerfield on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringHexToBytes)
-(NSData*) hexToBytes;
-(NSString*) md5String;
-(NSString*) sha256String;

+(NSString*) getRandomString:(int)length;
+(NSString*) getSaltString;
+(NSString*) getIVString;
@end