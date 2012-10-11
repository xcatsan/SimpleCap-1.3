//
//  SelectionListTableView.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 11/01/11.
//  Copyright 2011 . All rights reserved.
//

#import "SelectionListTableView.h"


@implementation SelectionListTableView

- (void)keyDown:(NSEvent *)theEvent
{
//	NSLog(@"%s|%@", __PRETTY_FUNCTION__, theEvent);
	switch ([theEvent keyCode]) {
		case 49:
			// non
			break;
		default:
			[super keyDown:theEvent];
			break;
	}
}

@end
