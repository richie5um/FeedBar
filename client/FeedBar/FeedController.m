//
//  FeedController.m
//  FeedBar
//
//  Created by RichS on 1/31/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import "FeedController.h"
#import "ASConnection.h"

@implementation FeedController

////////////////////////////////////////////////////////////////////////
-(void)loadFeedFromUrl:(NSString*)url {
    
    ASConnectionCompletionBlock connectionComplete = ^(ASConnection *connection,  NSError *error) {
        
        if ( nil == error ) {
            
            NSString* stringResult = [[connection downloadData] dataString];
            if ( nil != stringResult ) {
                
                FPFeed* feed = [self parseFeedFromString:stringResult];
                [self.delegate feedLoaded:feed];
            } else {
                NSLog( @"** No Result **" );
            }
        }
    };
    
    ASConnection* connection = [ASConnection connectionWithURL:[NSURL URLWithString:url]
                                                 progressBlock:nil
                                               completionBlock:connectionComplete];
    [connection start];    
}

////////////////////////////////////////////////////////////////////////
-(FPFeed*)parseFeedFromString:(NSString*)dataString {
        
	NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
	NSError *error = nil;
	FPFeed *feed = [FPParser parsedFeedWithData:data error:&error];
	return feed;
}

@end
