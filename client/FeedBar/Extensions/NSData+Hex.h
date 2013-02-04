//
//  NSData+Hex.h
//  DataLocker
//
//  Created by Paul Branton on 21/01/2012.
//  Copyright (c) 2012 AppSense. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData(Hex)
-(NSString*)bytesToHex;

+(NSData*) getRandomData:(int)length;

@end
