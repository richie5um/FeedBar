//
//  DragStatusView.m
//  fflickit
//
//  Created by RichS on 30/07/2012.
//
//

#import "DragStatusView.h"
#import "AppDelegate.h"

@implementation DragStatusView

///////////////////////////////////////////////////////////////////////////////////////
@synthesize statusItem;
@synthesize statusMenu;
@synthesize menuImage;

///////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(NSRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        // Register for drags
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,
                                           NSStringPboardType,
                                           NSURLPboardType, nil]];
    }
    
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////
- (void)drawRect:(NSRect)dirtyRect {
    
    // The status item will just be a solid rectangle
    //[[NSColor redColor] set];
    //NSRectFill([self bounds]);
    
    NSRect imageRect;
    NSRect controlRect;
    
    imageRect.origin.x = 0.0;
    imageRect.origin.y = 0.0;
    imageRect.size = [self.menuImage size];
    controlRect = [self bounds];
    
    // Determine the center-offset point
    double wDelta = (double)( controlRect.size.width - imageRect.size.width) / 2.0;
    double hDelta = (double)( controlRect.size.height - imageRect.size.height) / 2.0;
    
    // Map to the original image rect, but adjust by the center-offset point
    controlRect = imageRect;
    controlRect.origin.x += wDelta;
    controlRect.origin.y += hDelta;
    
    [self.menuImage drawInRect:controlRect
                      fromRect:imageRect
                     operation:NSCompositeCopy
                      fraction:1.0];
}

///////////////////////////////////////////////////////////////////////////////////////
// We want to copy the files
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    
    return NSDragOperationCopy;
}

///////////////////////////////////////////////////////////////////////////////////////
// Perform the drag and log the files that are dropped
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {
    
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
    
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
    
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSLog( @"Files: %@", files );
        if ( nil != files ) {
            for( NSString* file in files ) {
                if ( nil != file && 0 < [file length] ) {
                    [self.delegate fileDropped:file];
                }
            }
        }
    }
    
    return YES;
}

///////////////////////////////////////////////////////////////////////////////////////
- (void)mouseDown:(NSEvent *)event {
    
    //[[self menu] setDelegate:self.delegate];
    [self.statusItem popUpStatusItemMenu:self.statusMenu];
    [self setNeedsDisplay:YES];
}

///////////////////////////////////////////////////////////////////////////////////////
- (void)rightMouseDown:(NSEvent *)event {
    
    // Treat right-click just like left-click
    [self mouseDown:event];
}

/*
///////////////////////////////////////////////////////////////////////////////////////
- (void)menuWillOpen:(NSMenu *)menu {
    
    //isMenuVisible = YES;
    [self setNeedsDisplay:YES];
}

///////////////////////////////////////////////////////////////////////////////////////
- (void)menuDidClose:(NSMenu *)menu {
    
    //isMenuVisible = NO;
    //[menu setDelegate:nil];
    [self setNeedsDisplay:YES];
}
*/

@end
