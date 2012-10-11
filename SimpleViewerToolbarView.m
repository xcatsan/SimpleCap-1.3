//
//  SimpleViewerToolBarView.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/20.
//  Copyright 2010 . All rights reserved.
//

#define MARGIN_X	1.0
#define MARGIN_Y	1.0

#import "SimpleViewerToolbarView.h"


@implementation SimpleViewerToolbarView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
	
	NSRect rect = NSInsetRect(self.bounds, MARGIN_X, MARGIN_Y);
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.2] set];
	NSBezierPath* path = [NSBezierPath
						  bezierPathWithRoundedRect:rect
						  xRadius:2.0
						  yRadius:2.0];
	[path fill];
}

@end
