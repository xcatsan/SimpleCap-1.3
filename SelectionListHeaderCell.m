// Copyright (c) 2011 Hiroshi Hashiguchi
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights 
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is 
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


#import "SelectionListHeaderCell.h"

#define TRIANGLE_WIDTH	8
#define TRIANGLE_HEIGHT	7
#define MARGIN_X		4
#define MARGIN_Y		5
#define LINE_MARGIN_Y	2

@implementation SelectionListHeaderCell

- (id)initWithCell:(NSTableHeaderCell*)cell
{
	self = [super initTextCell:[cell stringValue]];
	if (self) {
		NSMutableAttributedString* attributedString =
		[[[NSMutableAttributedString alloc] initWithAttributedString:
		  [cell attributedStringValue]] autorelease];
		[attributedString addAttributes:
		 [NSDictionary dictionaryWithObject:[NSColor whiteColor]
									 forKey:NSForegroundColorAttributeName]
								  range:NSMakeRange(0, [attributedString length])];
		[self setAttributedStringValue: attributedString];
		
		_ascending = YES;
		_priority = 1;
	}
	return self;
			
}

+ (void)drawBackgroundInRect:(NSRect)rect
{
	NSArray* colorArray = [NSArray arrayWithObjects:
						   [NSColor colorWithDeviceWhite:1.0 alpha:0.1],
						   [NSColor colorWithDeviceWhite:0.0 alpha:0.2],
						   [NSColor colorWithDeviceWhite:0.0 alpha:0.4],
						   nil];
	NSGradient* gradient = [[NSGradient alloc] initWithColors:colorArray];
	[gradient drawInRect:rect angle:90.0];
	
	NSGraphicsContext* gc = [NSGraphicsContext currentContext];
	[gc saveGraphicsState];
	[gc setShouldAntialias:NO];
	
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path setLineWidth:1.0];
	NSPoint p = NSMakePoint(rect.origin.x, rect.origin.y+2.0);
	[path moveToPoint:p];
	
	p.y += rect.size.height-2.0;
	[path lineToPoint:p];
	p.x += rect.size.width;
	[path lineToPoint:p];
	
	p = NSMakePoint(rect.origin.x, rect.origin.y+1.0);
	[path moveToPoint:p];
	p.x += rect.size.width;
	[path lineToPoint:p];
	
	[[NSColor colorWithDeviceWhite:0.0 alpha:0.2] set];
	[path stroke];
	
	[gc restoreGraphicsState];
	
	
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	[SelectionListHeaderCell drawBackgroundInRect:cellFrame];

	NSRect stringFrame = cellFrame;
	if (_priority == 0) {
		stringFrame.size.width -= TRIANGLE_WIDTH;
	}
	stringFrame.origin.y += LINE_MARGIN_Y;
	[[self attributedStringValue] drawInRect:stringFrame];

	[self drawSortIndicatorWithFrame:cellFrame
							  inView:controlView
						   ascending:_ascending
							priority:_priority];		
}

/*
- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	NSLog(@"%s|%d", __PRETTY_FUNCTION__, flag);
}

*/

- (void)drawSortIndicatorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView ascending:(BOOL)ascending priority:(NSInteger)priority
{
	NSBezierPath* path = [NSBezierPath bezierPath];

	if (ascending) {
		NSPoint p = NSMakePoint(cellFrame.origin.x + cellFrame.size.width - TRIANGLE_WIDTH - MARGIN_X,
								cellFrame.origin.y + cellFrame.size.height - MARGIN_Y);
		[path moveToPoint:p];
		
		
		p.x += TRIANGLE_WIDTH/2.0;
		p.y -= TRIANGLE_HEIGHT;
		[path lineToPoint:p];
		
		p.x += TRIANGLE_WIDTH/2.0;
		p.y += TRIANGLE_HEIGHT;
		[path lineToPoint:p];

	} else {
		NSPoint p = NSMakePoint(cellFrame.origin.x + cellFrame.size.width - TRIANGLE_WIDTH - MARGIN_X,
								cellFrame.origin.y + MARGIN_Y);
		[path moveToPoint:p];
		
		
		p.x += TRIANGLE_WIDTH/2.0;
		p.y += TRIANGLE_HEIGHT;
		[path lineToPoint:p];
		
		p.x += TRIANGLE_WIDTH/2.0;
		p.y -= TRIANGLE_HEIGHT;
		[path lineToPoint:p];

	}

	[path closePath];

	if (_priority == 0) {
		[[NSColor whiteColor] set];
	} else {
		[[NSColor clearColor] set];
	}
	[path fill];		

}
	 
- (void)setSortAscending:(BOOL)ascending priority:(NSInteger)priority
{
	_ascending = ascending;
	_priority = priority;
}

@end
