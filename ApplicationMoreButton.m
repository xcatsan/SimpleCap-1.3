//
//  ApplicatinMoreButton.m
//  SimpleCap
//
//  Created by - on 10/05/03.
//  Copyright 2010 Hiroshi Hashiguchi. All rights reserved.
//

#import "ApplicationMoreButton.h"
#import "UserDefaults.h"

#define MENU_BUTTON_WIDTH	20
#define MENU_BUTTON_HEIGHT	16

@implementation ApplicationMoreButton
@synthesize target, action;

//- (id)initWithFrame:(NSRect)frame {
- (id)init {
	
	NSRect frame = NSMakeRect(0, 0, MENU_BUTTON_WIDTH, MENU_BUTTON_HEIGHT);
	self = [super initWithFrame:frame];
    if (self) {
		_image1 = [[NSImage imageNamed:@"viewer_more_app1"] retain];
		_image2 = [[NSImage imageNamed:@"viewer_more_app2"] retain];
		_image3 = [[NSImage imageNamed:@"viewer_more_app3"] retain];
		[UserDefaults addObserver:self forKey:UDKEY_VIEWER_BACKGROUND];
    }
    return self;
}

- (void) dealloc
{
	[_image1 release];
	[_image2 release];
	[_image3 release];
	[super dealloc];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
	int background = [[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue];
	
	NSImage* image;

	switch (background) {
		case 0:
			image = _image3;
			break;
		case 1:
			image = _image1;
			break;
		case 2:
			image = _image2;
			break;
		default:
			image = _image1;
			break;
	}

	[image drawAtPoint:NSZeroPoint
			  fromRect:NSZeroRect
			 operation:NSCompositeSourceOver
			  fraction:1.0];
	
}

- (void)mouseDown:(NSEvent*)theEvent
{
	[target performSelector:action withObject:self];
}

@end
