//
//  FeedController.h
//  FeedBar
//
//  Created by RichS on 1/31/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FeedParser.h"

////////////////////////////////////////////////////////////////////////
@protocol FeedControllerDelegate <NSObject>

@required
-(void)feedLoaded:(FPFeed*)feed;

@end

////////////////////////////////////////////////////////////////////////
@interface FeedController : NSObject

@property (nonatomic, strong) id<FeedControllerDelegate> delegate;

-(void)loadFeedFromUrl:(NSString*)url;

@end
