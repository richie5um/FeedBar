//
//  AppDelegate.h
//  FeedBar
//
//  Created by RichS on 1/31/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DragStatusView.h"
#import "FeedController.h"
#import "PreferencesViewController.h"
#import "ASWindowControllerDelegate.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, FeedControllerDelegate, FBWindowControllerDelegate> {
    
    DragStatusView* _dragView;
    NSStatusItem *_statusItem;
    IBOutlet NSMenu *_menuBarMenu;
    
    NSTimer* _feedTimer;
    FeedController* _feedController;
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) PreferencesViewController* preferencesViewController;

- (IBAction)menuBarPreferencesAction:(id)sender;
- (IBAction)menuBarRefreshAction:(id)sender;
- (IBAction)menuBarExitAction:(id)sender;

@end
