//
//  CaptureIconBarController.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/18.
//  Copyright 2010 . All rights reserved.
//

#import "CaptureIconBarController.h"
#import "ThinButtonBar.h"
#import "AppController.h"
#import "ApplicationMenu.h"

@implementation CaptureIconBarController

-(void)setFlipped
{
	[_button_bar setPosition:SC_BUTTON_POSITION_LEFT_BOTTOM];
		//	[_button_bar setMarginY:-20];
}

- (void)setHidden:(BOOL)hidden
{
	if (hidden) {
		[_button_bar hide];
	} else {
		[_button_bar show];
	}
}

- (id)initWithSuperView:(NSView*)superView appController:(AppController*)appController;
{
	if (self = [super init]) {
		_app_controller = appController;

		_button_bar = [[ThinButtonBar alloc] initWithFrame:NSZeroRect vertical:YES];
			//		[_button_bar setPosition:SC_BUTTON_POSITION_LEFT_BOTTOM];

		[_button_bar addButtonWithImageResource:@"captureiconbar_widgets"
							 alterImageResource:@"captureiconbar_widgets2"
											tag:CIB_TAG_WIDGETS
										tooltip:NSLocalizedString(@"CaptureWidget", @"")
										  group:nil
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"captureiconbar_application"
							 alterImageResource:@"captureiconbar_application2"
											tag:CIB_TAG_APPLICATION
										tooltip:NSLocalizedString(@"CaptureApplication", @"")
										  group:nil
							   isActOnMouseDown:YES];
		
		[_button_bar addButtonWithImageResource:@"captureiconbar_screen"
							 alterImageResource:@"captureiconbar_screen2"
											tag:CIB_TAG_SCREEN
										tooltip:NSLocalizedString(@"CaptureScreen", @"")
										  group:nil
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"captureiconbar_menu"
							 alterImageResource:@"captureiconbar_menu2"
											tag:CIB_TAG_MENU
										tooltip:NSLocalizedString(@"CaptureMenu", @"")
										  group:nil
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"captureiconbar_selection"
							 alterImageResource:@"captureiconbar_selection2"
											tag:CIB_TAG_SELECTION
										tooltip:NSLocalizedString(@"CaptureSelection", @"")
										  group:nil
							   isActOnMouseDown:NO];
		
		[_button_bar addButtonWithImageResource:@"captureiconbar_windows"
							 alterImageResource:@"captureiconbar_windows2"
											tag:CIB_TAG_WINDOWS
										tooltip:NSLocalizedString(@"CaptureWindow", @"")
										  group:nil
							   isActOnMouseDown:NO];
		
		[_button_bar setDelegate:self];
			//		[_button_bar setMarginX:-5];
			//		[_button_bar setMarginY:9];
		[_button_bar setMarginX:-7];
		[_button_bar setMarginY:10];
		[superView addSubview:_button_bar];
		
		[_button_bar show];
		
		_capture_app_menu = [[NSMenu alloc] initWithTitle:@"Applications"];
		[_capture_app_menu setDelegate:self];

	}
	
	return self;
}

- (void) dealloc
{
	[_button_bar release];
	[_capture_app_menu release];
	[super dealloc];
}


-(void)setSuperViewFrame:(NSRect)frame
{
	[_button_bar setButtonBarWithFrame:frame];
}

-(void)clickedAtTag:(NSNumber*)tag event:(NSEvent*)event
{
	switch ([tag intValue]) {
		case CIB_TAG_WINDOWS:
			[_app_controller captureWindow:self];
			break;
			
		case CIB_TAG_SELECTION:
			[_app_controller captureSelection:self];
			break;

		case CIB_TAG_MENU:
			[_app_controller captureMenu:self];
			break;
			
		case CIB_TAG_SCREEN:
			[_app_controller captureScreen:self];
			break;
			
		case CIB_TAG_APPLICATION:
			[NSMenu popUpContextMenu:_capture_app_menu withEvent:event forView:nil];
			break;
			
		case CIB_TAG_WIDGETS:
			[_app_controller captureWidget:self];
			break;
			
		default:
			break;
	}
}

- (void)menuWillOpen:(NSMenu *)menu
{
	if (menu == _capture_app_menu) {
		[_app_controller updateApplicationMenu:_capture_app_menu];
	}
}

@end
