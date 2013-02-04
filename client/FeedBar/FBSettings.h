//
//  ASSettings.h
//  ASDataCollector
//
//  Created by RichS on 1/16/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBSettings : NSObject

@property (nonatomic, strong) NSString* namespace;

-(id)objectForKey:(NSString*)key;
-(void)setObject:(id)object forKey:(NSString*)key;
-(void)removeObjectForKey:(NSString*)key;

-(id)objectForKey:(NSString*)key isSecure:(BOOL)secure;
-(void)setObject:(id)object forKey:(NSString*)key isSecure:(BOOL)secure;
-(void)removeObjectForKey:(NSString*)key isSecure:(BOOL)secure;

// Class
+(FBSettings*)sharedInstance;

@end
