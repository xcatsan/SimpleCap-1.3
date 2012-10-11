//
//  SimpleViewInfoView.m
//  SimpleCap
//
//  Created by - on 08/12/21.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SimpleViewerInfoView.h"


@implementation SimpleViewerInfoView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		NSMutableDictionary*dict = [[NSMutableDictionary alloc] init];
		
		[dict setObject:[NSFont boldSystemFontOfSize:12.0]
				 forKey: NSFontAttributeName];
		[dict setObject:[NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.00]
				 forKey:NSForegroundColorAttributeName];
		[dict setObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.75]
				 forKey:NSStrokeColorAttributeName];
		[dict setObject:[NSNumber numberWithFloat: -1.5]
				 forKey:NSStrokeWidthAttributeName];
		_attribute = dict;
    }
    return self;
}

- (void) dealloc
{
	[_attribute release];
	[_dir_info release];
	[super dealloc];
}

- (void)setRatio:(CGFloat)ratio
{
	_ratio = ratio;
}

#define INFORMATION_OFFSET_X (20.0-7.0)
#define INFORMATION_OFFSET_Y (4.0+6.0)
//#define DIR_INFO_OFFSET_X	12.0
#define DIR_INFO_OFFSET_X	5.0
#define DIR_INFO_OFFSET_Y	INFORMATION_OFFSET_Y


- (NSString*)infoString
{
	int ratio_str = (int)(_ratio*100);
	NSString *info = [NSString stringWithFormat:@"%d%%", ratio_str];
	return info;
}

- (NSSize)infoStringSize
{
	NSSize size = [[self infoString] sizeWithAttributes:_attribute];
	return size;
}

#define META_MARGIN	0
- (void)drawRect:(NSRect)rect {
	
	NSString* info = [self infoString];
	NSSize size = [info sizeWithAttributes:_attribute];
	NSRect bounds = [self bounds];
	NSPoint p = NSMakePoint(bounds.size.width - size.width - INFORMATION_OFFSET_X,
							INFORMATION_OFFSET_Y);
	NSPoint p2 = NSMakePoint(_dir_info_x + DIR_INFO_OFFSET_X, DIR_INFO_OFFSET_Y);
	
	[NSGraphicsContext saveGraphicsState];
	[info drawAtPoint:p withAttributes:_attribute];
	[_dir_info drawAtPoint:p2 withAttributes:_attribute];
	[NSGraphicsContext restoreGraphicsState];
	
	NSRect meta_fill = NSMakeRect(META_MARGIN, 32-META_MARGIN, bounds.size.width-META_MARGIN*2, 21);
	meta_fill = NSInsetRect(meta_fill, 4.0, 0.0);
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:meta_fill
														 xRadius:1.0
														 yRadius:1.0];
	[[NSColor colorWithDeviceWhite:1.0 alpha:0.1] set];
	[path fill];

}

- (void)setDirectoryInfomation:(NSString*)dir_info
{
	[dir_info retain];
	[_dir_info release];
	_dir_info = dir_info;
}

- (void)setDirInfoOffsetX:(CGFloat)x
{
	_dir_info_x = x;
}

// same code exists other file
- (void)mouseDown:(NSEvent *)theEvent
{
	NSWindow *window = [self window];
	NSPoint origin = [window frame].origin;
	NSPoint old_p = [window convertBaseToScreen:[theEvent locationInWindow]];
	while ((theEvent = [window nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask]) && ([theEvent type] != NSLeftMouseUp)) {
		NSPoint new_p = [window convertBaseToScreen:[theEvent locationInWindow]];
		origin.x += new_p.x - old_p.x;
		origin.y += new_p.y - old_p.y;
		[window setFrameOrigin:origin];
		old_p = new_p;
	}
}

@end
