//
//  SelectionHandler.h
//  SimpleCap
//
//  Created by - on 08/03/16.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HandlerBase.h"
#import "Handler.h"
#import "TimerClient.h"
#import "SelectionHistoryLayerManager.h"
#import "SelectionSizeDialogController.h"
#import "SelectionListViewController.h"

@class ThinButtonBar;
@class CaptureIconBarController;
@interface SelectionHandler : HandlerBase <Handler, TimerClient, SelectionHistoryLayerManagerDelegate, SelectionSizeDialogControllerDelegate, SelectionListViewControllerDelegate> {
	NSRect _rect;
	id _delegate;
	NSShadow *_shadow;
	CGFloat _resize_unit;

	int _state;
	int _previous_state;

	BOOL _is_display_info;
	BOOL _display_info;
	NSRect _display_info_rect;
	int _display_info_mode;	// 0=normal/1=hovered/2=pushed
	
	BOOL _display_imageformat;
	
	ThinButtonBar *_button_bar;		// operation buttons
	ThinButtonBar *_button_bar2;	// size history
	
	BOOL _display_knob;
	
	NSSize _mouse_pointer_offset;
	
	SelectionHistoryLayerManager* _selectionHistoryLayerManager;
	
	BOOL _instant_shot;
	NSRect _saved_rect;
	
	SelectionSizeDialogController* _dialogController;
	BOOL _display_dialog;
	
	SelectionListViewController* _selectionListViewController;
	
	NSRect _savedFrame;
	
	CaptureIconBarController* _capture_icon_bar_controller;

}

-(void)setRubberBandFrame:(NSRect)frame;

@end
