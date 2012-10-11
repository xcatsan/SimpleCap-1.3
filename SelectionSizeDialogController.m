//
//  SelectionSizeDialogController.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/09.
//  Copyright 2010 . All rights reserved.
//

#import "SelectionSizeDialogController.h"
#import "Screen.h"

@implementation SelectionSizeDialogController
@synthesize delegate = _delegate;

- (void)showWithSize:(NSSize)size
{
	if (_panel == nil) {
		NSNib* nib = [[NSNib alloc] initWithNibNamed:@"SelectionSize"
											  bundle:nil];
		BOOL result = [nib instantiateNibWithOwner:self
								   topLevelObjects:nil];
		[nib release];
		if (!result) {
			NSLog(@"Loading SelectionSize.xib is failed!");
			return;
		}
		[_panel setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
				 
		// adjust position
		NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
		NSRect panelFrame = [_panel frame];
		
		panelFrame.origin.x = (screenFrame.size.width - panelFrame.size.width) / 2.0;
		panelFrame.origin.y = (screenFrame.size.height - panelFrame.size.height) / 2.0;
		panelFrame.origin.y += screenFrame.origin.y;	// for Dock Height
		panelFrame.origin.y = panelFrame.origin.y * 0.3;
		[_panel setFrame:panelFrame display:YES];
		
		[_panel setLevel:_windowLevel];
	}
	[_width setFloatValue:size.width];
	[_height setFloatValue:size.height];
	[_panel makeKeyAndOrderFront:self];
	[NSApp activateIgnoringOtherApps:YES];
	[_width becomeFirstResponder];
}

- (void)hide
{
	[_panel orderOut:self];
}

- (IBAction)cancel:(id)sender
{
	[self hide];
	[_delegate didCancelSelectionDialogController:self];
}
- (BOOL)windowShouldClose:(id)sender
{
	[self hide];
	[_delegate didCancelSelectionDialogController:self];
	return YES;
}

- (NSSize)size
{
	NSString* widthString = [_width stringValue];
	NSString* heightString = [_height stringValue];
//	CGFloat width = floor([_width floatValue]);
//	CGFloat height = floor([_height floatValue]);
//  >>> -[NSCFString count]: unrecognized selector sent to instance 0xa0408218
	CGFloat width = floor([widthString floatValue]);
	CGFloat height = floor([heightString floatValue]);
	
	Screen* screen = [Screen defaultScreen];
	NSRect frame = [screen frame];
	
	if (width < 0) {
		width = 0;
	} else if (width >= frame.size.width) {
		width = frame.size.width;
	}
	if (height < 0) {
		height = 0;
	} else if (height >= frame.size.height) {
		height = frame.size.height;
	}
	
	NSSize size = NSMakeSize(width, height);
	return size;
}

- (void)setSize:(NSSize)size
{
	[_width setIntegerValue:(NSInteger)size.width];
	[_height setIntegerValue:(NSInteger)size.height];
}

- (IBAction)ok:(id)sender
{
	[self hide];
	[_delegate didFinishedSelectionDialogController:self size:[self size]];
}

- (IBAction)onTextField:(id)sender
{
	NSSize size = [self size];
	[self setSize:size];
	[_delegate didSetSelectionDialogController:self size:size];
	
}

/*
- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor
{
	NSLog(@"[2] %s|%@|%@", __PRETTY_FUNCTION__, control, fieldEditor);
	[control resignFirstResponder];
	return YES;
}
- (BOOL)textShouldEndEditing:(NSText *)aTextObject
{
	NSLog(@"[3] %s|%@", __PRETTY_FUNCTION__, aTextObject);
	return YES;
}
*/

- (void)setWindowLevel:(NSInteger)level
{
	_windowLevel = level;
}


@end
