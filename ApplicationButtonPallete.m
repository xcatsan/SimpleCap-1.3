//
//  ButtonPallete.m
//  MatrixSample
//
//  Created by - on 09/12/08.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import "ApplicationButtonPallete.h"
#import "ApplicationButtonCell.h"
#import "ApplicationButtonMatrix.h"
#import "UserDefaults.h"
#import "ApplicationEntry.h"
#import "ApplicationMoreButton.h"

#define LAYOUT_MARGIN	3.0

@implementation ApplicationButtonPallete

@synthesize target, action, arrayController, menuAction;

#pragma mark -
#pragma mark Utility
-(void)updateApplications
{
	for (ApplicationEntry* entry in [arrayController arrangedObjects]) {
		[self addButtonWithPath:entry.path];
	}

}

-(void)registObservers
{
	[arrayController addObserver:self
					  forKeyPath:@"arrangedObjects"
						 options:NSKeyValueObservingOptionNew
						 context:nil];
}
-(void)unregistObservers
{
	[arrayController removeObserver:self forKeyPath:@"arrangedObjects"];
}	

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	[matrix reset];
	[self updateApplications];
}

#pragma mark -
#pragma mark Initialize and Deallocation
-(id)init
{
	self = [super init];
	
	if (self) {
		matrix = [[[ApplicationButtonMatrix alloc] init] autorelease];
		[matrix setTarget:self];
		[matrix setAction:@selector(click:)];
		display_frame = NSZeroRect;

		menu_button = [[ApplicationMoreButton alloc] init];
		menu_button.target = self;
		menu_button.action = @selector(clickMenuButton:);
		[menu_button setHidden:YES];
	}
	return self;
}
- (void) dealloc
{
	matrix = nil;
	[menu_button release];
	[self unregistObservers];
	[super dealloc];
}

#pragma mark -
#pragma mark Managing Cell
-(void)addButtonWithPath:(NSString*)path
{
	ApplicationButtonCell* cell = [ApplicationButtonCell cellWithPath:path];
	NSArray* array = [NSArray arrayWithObject:cell];
	[matrix addRowWithCells:array];
	[matrix sizeToCells];
	[matrix setToolTip:cell.name forCell:cell];
	[self updateLayout];
}


#pragma mark -
#pragma mark Event Handling
-(void)click:(id)sender
{
	ApplicationButtonCell* selectedCell = [sender selectedCell];
	NSInteger row, column;
	[matrix getRow:&row column:&column ofCell:selectedCell];

	NSMethodSignature* signature = [[target class] instanceMethodSignatureForSelector:self.action];
	if (signature) {
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
		[invocation setSelector:self.action];
		[invocation setTarget:self.target];
		[invocation setArgument:&row atIndex:2];
		[invocation setArgument:&selectedCell atIndex:3];
		[invocation invoke];
	}
}

-(void)clickMenuButton:(id)sender
{
	/*
	if (number_of_displayed_icons >= [[arrayController arrangedObjects] count]) {
		return;
	}
	 */

	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Application Menu"] autorelease];

	NSUInteger index = 0;
	for (ApplicationEntry* entry in [arrayController arrangedObjects]) {
		if (index >= number_of_displayed_icons) {
			NSMenuItem* item = [[[NSMenuItem alloc] init] autorelease];
			[item setTitle:entry.name];
			[item setImage:entry.icon];
			[item setTarget:self.target];
			[item setAction:self.menuAction];
			[item setRepresentedObject:
			 [NSDictionary dictionaryWithObjectsAndKeys:entry.path, @"path", nil]];
			[menu addItem:item];
		}
		index++;
	}
	[NSMenu popUpContextMenu:menu withEvent:[[NSApplication sharedApplication] currentEvent] forView:nil];
}

#pragma mark -
#pragma mark Public method
-(void)addToView:(NSView*)view
{
	[view addSubview:matrix];
	[view addSubview:menu_button];
//	[view addSubview:matrix positioned:NSWindowBelow relativeTo:nil];
	contentView = view;			// only assign
}

-(void)setDisplayFrame:(NSRect)frame
{
	display_frame = frame;
}

-(void)updateLayout;
{
	NSSize matrix_size = [matrix frame].size;
	NSRect matrix_frame = display_frame;

	matrix_frame.origin.x +=
		display_frame.size.width - matrix_size.width;
	
	NSPoint menu_button_origin = matrix_frame.origin;

	matrix_frame.size.width = matrix_size.width;

	NSSize cellSize = [matrix cellSizeWithSpacing];

	number_of_displayed_icons = (int)((display_frame.size.height-cellSize.height*0.375) / cellSize.height);
	NSInteger matrix_row = [matrix numberOfRows];
	
	if (number_of_displayed_icons < matrix_row) {
		matrix_frame.size.height = number_of_displayed_icons * cellSize.height;
//		menu_button_origin.y += display_frame.size.height - matrix_frame.size.height - MENU_BUTTON_HEIGHT;
		menu_button_origin.x += 3;
		[menu_button setHidden:NO];
		[menu_button setFrameOrigin:menu_button_origin]; 
	} else {
		matrix_frame.size.height = display_frame.size.height;
		[menu_button setHidden:YES];
	}
	matrix_frame.origin.y += display_frame.size.height - matrix_frame.size.height;

	[matrix setFrame:matrix_frame];
}

- (void)setArrayController:(NSArrayController*)anArrayContoroller;
{
	[self unregistObservers];
	[anArrayContoroller retain];
	[arrayController release];
	arrayController = anArrayContoroller;
	[self registObservers];
	[matrix reset];
	[self updateApplications];
}

@end
