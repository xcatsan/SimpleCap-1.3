//
//  SimpleViewerBackgroundView.m
//  SimpleCap
//
//  Created by - on 09/01/17.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerBackgroundView.h"
#import "UserDefaults.h"
#import <QuartzCore/QuartzCore.h>

@implementation SimpleViewerBackgroundView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		[UserDefaults addObserver:self forKey:UDKEY_VIEWER_BACKGROUND];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	[self setNeedsDisplay:YES];
}

- (void) dealloc
{
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:UDKEY_VIEWER_BACKGROUND];
	[super dealloc];
}


#define PV_ICONS_HEIGHT	152
- (void)drawRect:(NSRect)rect {
	
	int background = [[UserDefaults valueForKey:UDKEY_VIEWER_BACKGROUND] intValue];
	if (background == 1) {
		CIFilter *filter = [CIFilter filterWithName:@"CICheckerboardGenerator"];
		[filter setDefaults];
		
		[filter setValue:[NSNumber numberWithInt:10] forKey:@"inputWidth"];
		[filter setValue:[CIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
				  forKey:@"inputColor0"];
		[filter setValue:[CIColor colorWithRed:0.75 green:0.75 blue:0.75 alpha:1.0]
				  forKey:@"inputColor1"];
		
		CIImage *ciimage = [filter valueForKey:kCIOutputImageKey];
		
		CIContext *context = [[NSGraphicsContext currentContext] CIContext];
		
		[context drawImage:ciimage
				   atPoint:CGPointZero
				  fromRect:NSRectToCGRect([self bounds])];
	} else if (background == 2) {
		[[NSColor whiteColor] set];
		NSRectFill(rect);
	}
	
	
	// for capture icons
	/*
	NSColor* backgroundColor;
	NSColor* lineColor;
	NSRect iconsRect = NSMakeRect(3, self.frame.size.height-PV_ICONS_HEIGHT-3, 23, PV_ICONS_HEIGHT);
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:iconsRect
														 xRadius:2
														 yRadius:2];
	switch (background) {
		case 0:
			backgroundColor = [NSColor colorWithDeviceWhite:1.0 alpha:0.2];
			lineColor = [NSColor colorWithDeviceWhite:0.0 alpha:0.75];
			break;
		case 1:
			backgroundColor = [NSColor colorWithDeviceWhite:0.75 alpha:1.0];
			lineColor = [NSColor colorWithDeviceWhite:0.0 alpha:1.0];
			break;
		case 2:
			backgroundColor = [NSColor colorWithDeviceWhite:0.0 alpha:0.25];
			lineColor = [NSColor colorWithDeviceWhite:0.0 alpha:0.75];
			break;
		default:
			break;
	}
	[backgroundColor set];
	[path fill];
	[path setLineWidth:0.25];
	[lineColor set];
	[path stroke];
	 */
}

@end
