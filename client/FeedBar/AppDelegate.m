//
//  AppDelegate.m
//  FeedBar
//
//  Created by RichS on 1/31/13.
//  Copyright (c) 2013 Rich Somerfield. All rights reserved.
//

#import "AppDelegate.h"
#import "Helpers.h"
#import "FBSettings.h"
#import "FBGlobals.h"

@implementation AppDelegate

////////////////////////////////////////////////////////////////////////
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    // Insert code here to initialize your application
    [Helpers showIconInDock:NO];
    
    if ( YES != [Helpers isLaunchAtStartup] ) {
        [Helpers toggleLaunchAtStartup];
    }
}

////////////////////////////////////////////////////////////////////////
-(void)awakeFromNib {
    
    [self initialiseApp];
}

////////////////////////////////////////////////////////////////////////
-(void)applicationWillTerminate:(NSNotification *)notification {
    
    [self deInitialiseApp];
}

////////////////////////////////////////////////////////////////////////
-(void)initialiseApp {
    
    // Self initialise
    [self initialiseMenuBarIcon];
    [self initialiseFeedController];
}

////////////////////////////////////////////////////////////////////////
-(void)deInitialiseApp {
    
}

////////////////////////////////////////////////////////////////////////
-(void)initialiseMenuBarIcon {
    
    // Initialise the menubar
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [_statusItem setMenu:_menuBarMenu];
    [_statusItem setHighlightMode:YES];
    [_menuBarMenu setDelegate:self];
    
    CGFloat menuSize = [[NSStatusBar systemStatusBar] thickness];
    _dragView = [[DragStatusView alloc] initWithFrame:NSMakeRect(0, 0, menuSize, menuSize)];
    _dragView.statusItem = _statusItem;
    _dragView.statusMenu = _menuBarMenu;
    
    [self updateMenuBarIcon:NO];
    
    [_statusItem setView:_dragView];
}

////////////////////////////////////////////////////////////////////////
-(void)initialiseFeedController {
    
    _feedController = [[FeedController alloc] init];
    _feedController.delegate = self;
    
    [self updateFeeds];
}

////////////////////////////////////////////////////////////////////////
-(void)initialiseFeedTimer {
    
    _feedTimer = [NSTimer scheduledTimerWithTimeInterval:60.0f * 60.0f
                                                  target:self
                                                selector:@selector(feedTimerEvent:)
                                                userInfo:nil
                                                 repeats:NO];
}

////////////////////////////////////////////////////////////////////////
-(void)deInitialiseFeedTimer {
    
    [_feedTimer invalidate];
    _feedTimer = nil;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)feedTimerEvent:(NSTimer*)theTimer {
    
    [self updateFeeds];
}

////////////////////////////////////////////////////////////////////////
-(void)updateFeeds {
    
    // Stop the feed timer
    [self deInitialiseFeedTimer];
    
    [self updateMenuBarIcon:NO];
    NSString* url = [[FBSettings sharedInstance] objectForKey:kFBPreferencesFeedURL];
    [_feedController loadFeedFromUrl:url];
}

////////////////////////////////////////////////////////////////////////
-(void)feedLoaded:(FPFeed*)feed {
    
    // Remove existing entries
    NSUInteger index = [_menuBarMenu.itemArray count];
    while ( 0 < index ) {
        
        NSMenuItem* item = [_menuBarMenu itemAtIndex:index-1];
        if ( nil != item.representedObject ) {
            
            [_menuBarMenu removeItem:item];
        }
        --index;
    }
    
    // Add new entries
    for( FPItem* item in feed.items ) {
        
        SEL actionOpen = @selector(actionMenuItemOpen:);
        
        NSMenuItem* menuItem = [[NSMenuItem allocWithZone:[NSMenu menuZone]]
                                initWithTitle:item.title
                                action:actionOpen
                                keyEquivalent:@""];
        
        
        menuItem.image = [NSImage imageNamed:@"News.png"];
        [menuItem.offStateImage setTemplate:YES];
        
        menuItem.target = self;
        menuItem.representedObject = menuItem;
        [_menuBarMenu insertItem:menuItem atIndex:0];
    }
    
    // Update the menu bar to reflect new entries
    BOOL newEntries = YES;
    [self updateMenuBarIcon:newEntries];
    
    // Re-start the feed timer
    [self initialiseFeedTimer];
}

////////////////////////////////////////////////////////////////////////
-(void)updateMenuBarIcon:(BOOL)colorIcon {
    
    NSImage *statusIcon;
    
    if ( colorIcon ) {
        statusIcon = [NSImage imageNamed:@"FeedBar.icns"];
    } else {
        statusIcon = [NSImage imageNamed:@"FeedBarBW.icns"];
    }
    
    CGFloat menuSize = [[NSStatusBar systemStatusBar] thickness];
    CGFloat iconSize = menuSize * .7;
    [statusIcon setSize:NSMakeSize(iconSize, iconSize)];
    
    _dragView.menuImage = statusIcon;
    
    // Force a redraw
    [_dragView setNeedsDisplay:YES];
}

////////////////////////////////////////////////////////////////////////
- (IBAction)menuBarPreferencesAction:(id)sender {
    
    [self showPreferencesView];
}

////////////////////////////////////////////////////////////////////////
- (IBAction)menuBarRefreshAction:(id)sender {
    
    [self updateFeeds];
}

////////////////////////////////////////////////////////////////////////
- (IBAction)menuBarExitAction:(id)sender {

    // Terminate the app, but do so at the start of the next event loop.
    // Keeps it cleaner than just exiting now!
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];    
}

////////////////////////////////////////////////////////////////////////
-(void)actionMenuItemOpen:(id)object {
    
    NSLog(@"MenuItemOpen");
    FPItem* item = [object representedObject];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[item.link href]]];
}

////////////////////////////////////////////////////////////////////////
-(void)showPreferencesView {
    
    if ( nil == self.preferencesViewController ) {
        
        self.preferencesViewController = [[PreferencesViewController alloc] initWithWindowNibName:@"PreferencesViewController"];
        self.preferencesViewController.delegate = self;
    }
    
    NSDictionary* fields = @{
                             kFBPreferencesLaunchAtLogin : [NSNumber numberWithBool:[Helpers isLaunchAtStartup]],
                             kFBPreferencesFeedURL : [[FBSettings sharedInstance] objectForKey:kFBPreferencesFeedURL]
                             };
    [self.preferencesViewController initialiseFields:fields];
    
    // Bring the window to the front
    NSApplication *thisApp = [NSApplication sharedApplication];
    [thisApp activateIgnoringOtherApps:YES];
    
    [[self.preferencesViewController window] makeKeyAndOrderFront:self];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
-(void)windowControllerOKAction:(id)sender withFields:(NSDictionary*)fields {
    
    if ( sender == self.preferencesViewController ) {
        
        for( NSString* key in [fields keyEnumerator]) {
            
            if ( [key isEqualToString:kFBPreferencesLaunchAtLogin] ) {
                NSNumber* isEnabled = [fields objectForKey:kFBPreferencesLaunchAtLogin];
                if ( [isEnabled boolValue] != [Helpers isLaunchAtStartup] ) {
                    [Helpers toggleLaunchAtStartup];
                }
            } else {
                [[FBSettings sharedInstance] setObject:[fields objectForKey:key] forKey:key];
            }
        }
    }
    
    [self updateFeeds];
}

@end
