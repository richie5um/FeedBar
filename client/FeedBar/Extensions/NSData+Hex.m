//
//  NSData+Hex.m
//  DataLocker
//
//  Created by Paul Branton on 21/01/2012.
//  Copyright (c) 2012 AppSense. All rights reserved.
//

#import "NSData+Hex.h"

@implementation NSData(Hex)


-(NSString*)bytesToHex{
    NSMutableString* ivStr = [NSMutableString string];
    unsigned char *bytePtr = (unsigned char *)[self bytes];

	int ii = 0;
	for (ii = 0; ii < [self length] ; ii++){
		[ivStr appendFormat:@"%02x", bytePtr[ii]];
    }
                      
    
    return ivStr;
}

+(NSData*) getRandomData:(int)length{
	NSMutableData* randomData = [NSMutableData dataWithLength:length];
	int ii = 0;
    unsigned char *byteBuffer = [randomData mutableBytes];
	for (ii = 0; ii < length; ++ii){
		byteBuffer[ii] =  arc4random()&0xff;
    }
    
    return randomData;
}

@end
