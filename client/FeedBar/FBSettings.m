//
//  ASSettings.m
//  ASDataCollector
//
//  Created by RichS on 1/16/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import "FBSettings.h"
#import "FBDefaults.h"

//////////////////////////////////////////////////////////////////////////////////////////////////////
static FBSettings *_sharedInstance;

@implementation FBSettings

//////////////////////////////////////////////////////////////////////////////////////////////////////
+(FBSettings*)sharedInstance {
    
    @synchronized(self) {
        if ( nil == _sharedInstance) {
            
            _sharedInstance = [[FBSettings alloc] init];
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
	}
	return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(NSString*)namespace {
    
    // RichS TODO: Until I can work out the best way to handle per-user settings, there are no per-user settings.
    return @"DEFAULT";
    
    if ( nil == _namespace || 0 == [_namespace length] ) {
        _namespace = @"DEFAULT";
    }
    
    return _namespace;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)objectForKey:(NSString*)key {
    
    return [self objectForKey:key isSecure:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setObject:(id)object forKey:(NSString*)key {

    [self setObject:object forKey:key isSecure:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObjectForKey:(NSString*)key {

    [self removeObjectForKey:key isSecure:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(id)objectForKey:(NSString*)key isSecure:(BOOL)secure {

    NSString* internalKey = [NSString stringWithFormat:@"%@:%@", self.namespace, key];
    
    if ( YES == secure ) {
        // RichS TODO: Needs implementing as a secure store!!
        return [self objectForKey:key isSecure:NO];
    } else {
        id value = [[NSUserDefaults standardUserDefaults] objectForKey:internalKey];
        if ( nil == value ) {
            value = [[FBDefaults sharedInstance] defaultForKey:key];
        }
        return value;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)setObject:(id)object forKey:(NSString*)key isSecure:(BOOL)secure {
    
    NSString* internalKey = [NSString stringWithFormat:@"%@:%@", self.namespace, key];
    
    if ( YES == secure ) {
        // RichS TODO: Needs implementing as a secure store!!
        [self setObject:object forKey:key isSecure:NO];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:object forKey:internalKey];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)removeObjectForKey:(NSString*)key isSecure:(BOOL)secure {
    
    NSString* internalKey = [NSString stringWithFormat:@"%@:%@", self.namespace, key];
    
    if ( YES == secure ) {
        // RichS TODO: Needs implementing as a secure store!!
        [self removeObjectForKey:key isSecure:NO];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:internalKey];
    }
}

@end
