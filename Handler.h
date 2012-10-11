//
//  Handler.h
//  SimpleCap
//
//  Created by - on 08/03/23.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WindowLayer.h"

@protocol Handler

- (void)reset;
- (void)setup;
- (BOOL)startWithObject:(id)object;
- (void)tearDown;
- (void)drawRect:(NSRect)rect;
- (void)mouseMoved:(NSEvent *)theEvent;
- (void)mouseDown:(NSEvent *)theEvent;
- (void)mouseUp:(NSEvent *)theEvent;
- (void)keyDown:(NSEvent *)theEvent;

- (NSMenu *)menuForEvent:(NSEvent *)theEvent;
- (void)setupQuickConfigMenu:(NSMenu*)menu;
- (void)changedImageFormatTo:(int)image_format;
- (void)willCancel;

// property
- (NSInteger)windowLevel;

- (void)magnifyWithEvent:(NSEvent *)event;
- (void)rotateWithEvent:(NSEvent *)event;
- (void)swipeWithEvent:(NSEvent *)event;

@end

@interface NSEvent ()
#if MAC_OS_X_VERSION_MAX_ALLOWED <= MAC_OS_X_VERSION_10_5
- (CGFloat)magnification;
- (CGFloat)rotation;
#endif
@end
