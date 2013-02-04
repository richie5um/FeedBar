//
//  NSString+Hex.m
//  DataLocker
//
//  Created by Rich Somerfield on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSString+Hex.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (NSStringHexToBytes)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSData*) hexToBytes {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) md5String {
    
	NSData* inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
	unsigned char outputData[CC_MD5_DIGEST_LENGTH];
	CC_MD5([inputData bytes], (unsigned int)[inputData length], outputData);
    
	NSMutableString* hashStr = [NSMutableString string];
	int i = 0;
	for (i = 0; i < CC_MD5_DIGEST_LENGTH; ++i)
		[hashStr appendFormat:@"%02x", outputData[i]];
    
	return hashStr;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*) sha256String {
    
    NSData* inputData = [self dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char outputData[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256([inputData bytes], (CC_LONG)[inputData length], outputData);
    
    NSMutableString* hashStr = [NSMutableString string];
    int i = 0;
    for (i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
        [hashStr appendFormat:@"%02x", outputData[i]];
    }
    
    return hashStr;
}

+(NSString*) getRandomString:(int)length{
	NSMutableString* randomStr = [NSMutableString string];
	int ii = 0;
	for (ii = 0; ii < length; ++ii){
		[randomStr appendFormat:@"%02x", arc4random()&0xff];
    }
    
    return randomStr;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(NSString*) getSaltString {

	NSMutableString* saltStr = [NSMutableString string];
	int i = 0;
	for (i = 0; i < 16; ++i){
		[saltStr appendFormat:@"%02x", arc4random()&0xff];
    }

    return saltStr;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+(NSString*) getIVString {
	NSMutableString* ivStr = [NSMutableString string];
	int i = 0;
	for (i = 0; i < 16; ++i){
		[ivStr appendFormat:@"%02x", arc4random()&0xff];
    }

    return ivStr;
}

@end
