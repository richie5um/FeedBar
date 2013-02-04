//
//  ASDefaults.h
//  ASDataCollector
//
//  Created by RichS on 1/16/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBDefaults : NSObject

@property (nonatomic, strong) NSDictionary* defaults;

-(id)defaultForKey:(NSString*)key;

// Class
+(FBDefaults*)sharedInstance;

@end
