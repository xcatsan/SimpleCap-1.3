//
//  SelectionListPanel.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/12/02.
//  Copyright 2010 . All rights reserved.
//

#import "SelectionListPanel.h"
#import "SelectionListViewController.h"

@implementation SelectionListPanel

/*
- (id) init
{
	self = [super initWithContentRect:NSMakeRect(100, 100, 295, 301)
							styleMask:NSHUDWindowMask
									| NSResizableWindowMask
									| NSClosableWindowMask
									| NSUtilityWindowMask
									| NSNonactivatingPanelMask
							  backing:NSBackingStoreBuffered
								defer:NO];
	if (self != nil) {
		//		[self setBecomesKeyOnlyIfNeeded:YES];
		[self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
		[self setMinSize:NSMakeSize(250, 220)];
		[self setShowsResizeIndicator:YES];
	
	}
	return self;
}
*/

- (void)keyDown:(NSEvent *)event
{
//	NSLog(@"keyCode=%d", [event keyCode]);
	int command_flag = [event modifierFlags] & NSCommandKeyMask;
	int shift_flag = [event modifierFlags] & NSShiftKeyMask;

	switch ([event keyCode]) {
		case 37:
			// 'L'
			if (shift_flag) {
				[_viewController switchPreviousTab];				
			} else{
				[_viewController switchNextTab];
			}
			break;
			
		case 123:
			// left arrow
			if (command_flag) {
				[_viewController movePreviousTab];
			}
			break;
			
		case 124:
			// right arrow
			if (command_flag) {
				[_viewController moveNextTab];
			}
			break;
			
		case 51:
			// delete
			[_viewController removeSelection:self];
			break;

		case 53:
			// ESC
			[_viewController hide];
			break;
		default:
			break;
	}
}

- (void)redraw
{
	return;	// nothing
	
	/*
	NSRect frame = self.frame;
	frame.size.width += 1.0;
	[self setFrame:frame display:NO animate:NO];
	frame.size.width -= 1.0;
	[self setFrame:frame display:YES animate:NO];
	*/
}
@end
