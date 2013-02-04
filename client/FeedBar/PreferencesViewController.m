//
//  PreferencesViewController.m
//  ASDataCollector
//
//  Created by RichS on 1/15/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import "PreferencesViewController.h"
#import "FBGlobals.h"

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithWindow:(NSWindow *)window {
    
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)windowDidLoad {
    
    [super windowDidLoad];
    
    // Prevent the user from moving the UI
    [self.window setMovable:NO];
    [self displayFields];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)initialiseFields:(NSDictionary*)fields {
    
    self.fields = fields;
    
    [self displayFields];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)displayFields {
    
    NSNumber* value = [self.fields objectForKey:kFBPreferencesLaunchAtLogin];
    [self.launchAtLoginCheck setState:[value boolValue] ? NSOnState : NSOffState];
    
    NSString* string = [self.fields objectForKey:kFBPreferencesFeedURL];
    [self.textFieldFeedURL setStringValue:string];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)okAction:(id)sender {
    
    NSDictionary* newFields = @{
        kFBPreferencesLaunchAtLogin : [NSNumber numberWithBool:(NSOnState == [self.launchAtLoginCheck state])],
        kFBPreferencesFeedURL : [self.textFieldFeedURL stringValue]
    };
    
    [self.delegate windowControllerOKAction:self withFields:newFields];
    
    [self close];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)cancelAction:(id)sender {
    [self close];
}

@end
