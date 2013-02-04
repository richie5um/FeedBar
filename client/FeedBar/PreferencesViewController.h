//
//  PreferencesViewController.h
//  ASDataCollector
//
//  Created by RichS on 1/15/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ASWindowControllerDelegate.h"

@interface PreferencesViewController : NSWindowController

@property (nonatomic, strong) id<FBWindowControllerDelegate> delegate;

@property (nonatomic, strong) NSDictionary* fields;

@property (weak) IBOutlet NSButton *launchAtLoginCheck;
@property (weak) IBOutlet NSTextField *textFieldFeedURL;

-(void)initialiseFields:(NSDictionary*)fields;
-(void)displayFields;

-(IBAction)cancelAction:(id)sender;
-(IBAction)okAction:(id)sender;

@end
