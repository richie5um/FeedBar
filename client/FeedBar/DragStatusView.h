//
//  DragStatusView.h
//  fflickit
//
//  Created by RichS on 30/07/2012.
//
//

#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////
@protocol DragStatusViewDelegate <NSObject>

@required
-(void)fileDropped:(NSString*)file;

@end

////////////////////////////////////////////////////////////////////////
@interface DragStatusView : NSView

@property (strong, nonatomic) id<DragStatusViewDelegate>delegate;

@property (strong, atomic) NSStatusItem* statusItem;
@property (strong, atomic) NSMenu* statusMenu;
@property (strong, nonatomic) NSImage* menuImage;

@end
