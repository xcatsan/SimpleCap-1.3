//
//  CaptureOptionView.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 11/01/13.
//  Copyright 2011 . All rights reserved.
//

#import "CaptureOptionView.h"

@implementation CaptureOptionView
@synthesize image = image_;


#pragma mark Service methods (private)
- (void)_callBack:(NSTimer*)timer
{	
	CGFloat alpha = [self alphaValue];
	alpha = alpha - decrementValue_;
	if (alpha <= 0) {
		alpha = 0.0;
		[timer_ invalidate];
		self.image = nil;
		timer_ = nil;
	}
	[self setAlphaValue:alpha];
	
	switch (status_) {
		case kCaptureOptionFlashSelection:
			break;
		case kCaptureOptionFlashImage:
			decrementValue_ = decrementValue_ * 1.5;
			break;
		default:
			break;
	}
	
}

- (void)_stopAnimation
{
	if (timer_ && [timer_ isValid]) {
		[timer_ invalidate];
	}
	timer_ = nil;
}

- (void)_startAnimation
{
	[self setAlphaValue:startValue_];
	timer_ = [NSTimer scheduledTimerWithTimeInterval:0.1
											  target:self
											selector:@selector(_callBack:)
											userInfo:nil
											 repeats:YES];
	[self setNeedsDisplay:YES];
}

- (void)_setStatus:(CaptureOptionStatus)status
{
	[self _stopAnimation];

	status_ = status;
	self.image = nil;
	[self setAlphaValue:0.0];
	self.frame = NSZeroRect;
	
	switch (status_) {
		case kCaptureOptionFlashSelection:
			startValue_ = 0.5;
			decrementValue_ = 0.25;
			break;
		case kCaptureOptionFlashImage:
			startValue_ = 2.0;
			decrementValue_ = 0.15;
			break;
		default:
			startValue_ = 1.0;
			decrementValue_ = 0.25;
			break;
	}
}


#pragma mark -
#pragma mark Initialization and deallocation
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[self _setStatus:kCaptureOptionNone];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {

	NSSize imageSize = self.image.size;
	NSSize viewSize = self.frame.size;
	NSPoint p = NSMakePoint((viewSize.width-imageSize.width)/2.0,
							(viewSize.height-imageSize.height)/2.0);
	
	switch (status_) {
		case kCaptureOptionFlashSelection:
			[[NSColor whiteColor] set];
			NSRectFill(rect);
			break;
			
		case kCaptureOptionFlashImage:
			[self.image drawAtPoint:p
						   fromRect:NSZeroRect
						  operation:NSCompositeSourceOver
						   fraction:1.0];		
			break;
	}
}

- (void) dealloc
{
	self.image = nil;
	timer_ = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Overriden methods
- (BOOL)isOpaque
{
	return NO;
}


#pragma mark -
#pragma mark Service Methods
- (void)showImage:(NSImage*)image frame:(NSRect)frame
{
	[self _setStatus:kCaptureOptionFlashImage];

	self.frame = frame;
	self.image = image;
	
	[self _startAnimation];
}

- (void)flashInframe:(NSRect)frame
{
	[self _setStatus:kCaptureOptionFlashSelection];

	self.frame = frame;
	[self _startAnimation];
}

@end
