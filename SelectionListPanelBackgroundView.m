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


#import "SelectionListPanelBackgroundView.h"

@implementation SelectionListPanelBackgroundView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
	
	NSRect rect = self.frame;
	rect.size.height += 15;

	[[NSColor clearColor] set];
	NSRectFill(rect);

	NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect
														 xRadius:10
														 yRadius:10];
//	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.3] set];
	[[NSColor colorWithCalibratedWhite:0.25 alpha:0.75] set];
	[path fill];
//	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.4] set];
//	[path stroke];
}

@end
