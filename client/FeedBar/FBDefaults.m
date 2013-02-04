//
//  ASDefaults.m
//  ASDataCollector
//
//  Created by RichS on 1/16/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import "FBDefaults.h"
#import "FBGlobals.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////
static FBDefaults *_sharedInstance;

@implementation FBDefaults

//////////////////////////////////////////////////////////////////////////////////////////////////////
+(FBDefaults*)sharedInstance {
    
    @synchronized(self) {
        if ( nil == _sharedInstance) {
            _sharedInstance = [[FBDefaults alloc] init];
        }
    }
    return _sharedInstance;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Methods

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)init {
    
	self = [super init];
	if(self) {
        
        _defaults = @{
            kFBPreferencesFeedURL : kFBPreferencesFeedURLDefault,
            kFBPreferencesLaunchAtLogin : [NSNumber numberWithBool:YES]
        };
        
	}
	return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)defaultForKey:(NSString*)key {
    
    return [self.defaults objectForKey:key];
}

@end
