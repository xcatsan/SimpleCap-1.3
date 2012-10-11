//
//  SimpleViewerWindow.m
//  SimpleCap
//
//  Created by - on 08/12/19.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerPanel.h"
#import "SimpleViewerController.h"
#import "UserDefaults.h"

@implementation SimpleViewerPanel

- (id)initWithController:(SimpleViewerController*)controller
{
	NSRect frame = NSZeroRect;
	self = [super initWithContentRect:frame
							styleMask:NSResizableWindowMask|NSHUDWindowMask| NSClosableWindowMask | NSUtilityWindowMask | NSNonactivatingPanelMask
							  backing:NSBackingStoreBuffered
								defer:NO];

	if (self) {
		_controller = [controller retain];
		[self setDisplaysWhenScreenProfileChanges:YES];
		[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
		[self setTitle:@"Simple Viewer"];
		[self setMovableByWindowBackground:NO];
		
		[UserDefaults addObserver:self forKey:UDKEY_VIEWER_ALWAYS_ON_TOP];

	}
	return self;
}

- (BOOL)canBecomeKeyWindow
{
	return YES;
}

- (void) dealloc
{
	[_controller release];
	[super dealloc];
}


#define FADE_DURATION	0.15
#define ZOOM_DURATION	0.35
- (void)show
{
	if (![self isVisible]) {
		[self setAlphaValue:0.0];
	}
	BOOL is_floating = [[UserDefaults valueForKey:UDKEY_VIEWER_ALWAYS_ON_TOP] boolValue];
	[self setFloatingPanel:YES];
	[self makeKeyAndOrderFront:nil];
	[NSApp activateIgnoringOtherApps:YES];
	[self setFloatingPanel:is_floating];

	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:self forKey:NSViewAnimationTargetKey];
	[dict setObject:NSViewAnimationFadeInEffect forKey:NSViewAnimationEffectKey];
	[dict setObject:[NSValue valueWithRect:[self frame]] forKey:NSViewAnimationStartFrameKey];
	[dict setObject:[NSValue valueWithRect:[self frame]] forKey:NSViewAnimationEndFrameKey];
	
	NSViewAnimation *anim = [[NSViewAnimation alloc]
							 initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[anim setDuration:FADE_DURATION];
	[anim setAnimationCurve:NSAnimationEaseIn];
	
	[anim startAnimation];
	[anim release];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	// only in fade out situation
	[self orderOut:nil];
}

- (BOOL)isOpened
{
	if (![self isVisible] || [self alphaValue]==0) {
		return NO;
	}
	return YES;
}

- (void)hide
{
	if (![self isOpened]) {
		return;
	}
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:self forKey:NSViewAnimationTargetKey];
	[dict setObject:NSViewAnimationFadeOutEffect forKey:NSViewAnimationEffectKey];
	
	NSViewAnimation *anim = [[NSViewAnimation alloc]
							 initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[anim setDuration:FADE_DURATION];
	[anim setAnimationCurve:NSAnimationEaseIn];
	
	[anim setDelegate:self];
	[anim startAnimation];
	[anim release];

}

#define SCALE_FACTOR	0.1
#define	FRAME_RATE		60
- (void)zoomInWithStartFrame:(NSRect)start_frame
{
	// QuickLookとの違い 12/27
	// (1) スムーズさに欠ける
	// (2) ウィンドウのタイトルを含む全部が拡大・縮小の対象になっている。
	[self setAlphaValue:0.0];
	[self makeKeyAndOrderFront:nil];
	
	NSRect frame;
	frame.size.width  = start_frame.size.width  * SCALE_FACTOR;
	frame.size.height = start_frame.size.height * SCALE_FACTOR;
	frame.origin.x    = start_frame.origin.x +
		(start_frame.size.width - frame.size.width) / 2.0;
	frame.origin.y    = start_frame.origin.y +
		(start_frame.size.height - frame.size.height) / 2.0;

	// adjust to screen
	NSScreen *screen = [NSScreen mainScreen];
	frame.origin.y = [screen frame].size.height - frame.origin.y;
	
	NSMutableDictionary* dict = [NSMutableDictionary dictionary];
	[dict setObject:self forKey:NSViewAnimationTargetKey];
	[dict setObject:[NSValue valueWithRect:frame] forKey:NSViewAnimationStartFrameKey];
	[dict setObject:[NSValue valueWithRect:[self frame]] forKey:NSViewAnimationEndFrameKey];
	
	NSViewAnimation *anim = [[NSViewAnimation alloc]
							 initWithViewAnimations:[NSArray arrayWithObject:dict]];
	[anim setDuration:ZOOM_DURATION];
	[anim setAnimationBlockingMode:NSAnimationBlocking];
	[anim setAnimationCurve:NSAnimationEaseIn];
	[anim setFrameRate:FRAME_RATE];
	
	[anim startAnimation];
	[anim release];
}

- (void)close
{
	[self hide];
}

- (void)keyDown:(NSEvent *)event
{
	[_controller keyDown:event];
}

- (void)flagsChanged:(NSEvent *)theEvent
{
	[_controller flagsChanged:theEvent];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	BOOL is_floating = [[UserDefaults valueForKey:UDKEY_VIEWER_ALWAYS_ON_TOP] boolValue];
	[self setFloatingPanel:is_floating];
}


- (void)saveFrame
{
	[UserDefaults setValue:NSStringFromRect([self frame])
					forKey:UDKEY_VIEWER_WINDOW_POSITION];
	[UserDefaults save];
}

/*
 NSEvent: type=Swipe loc=(325,153) time=35110.6 flags=0x100 win=0x1436e0 winNum=5070 ctxt=0x214cf deltaX=-1.000000 deltaY=0.000000
 */
#ifndef NSEventTypeSwipe
#define NSEventTypeSwipe 31
#endif
- (void)swipeWithEvent:(NSEvent *)event
{
	if ([event type] == NSEventTypeSwipe) {
		CGFloat deltaX = [event deltaX];
		if (deltaX < 0) {
			[_controller clickedNext:nil];
		} else if (deltaX > 0) {
			[_controller clickedPrevious:nil];
		}
	}
}
@end
