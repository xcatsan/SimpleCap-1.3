//
//  SelectionSizeDialogController.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/09.
//  Copyright 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SelectionSizeDialogController;
@protocol SelectionSizeDialogControllerDelegate

- (void)didSetSelectionDialogController:(SelectionSizeDialogController*)controller size:(NSSize)size;
- (void)didFinishedSelectionDialogController:(SelectionSizeDialogController*)controller size:(NSSize)size;
- (void)didCancelSelectionDialogController:(SelectionSizeDialogController*)controller;

@end


@interface SelectionSizeDialogController : NSObject {

	IBOutlet NSTextField* _width;
	IBOutlet NSTextField* _height;
	
	IBOutlet NSPanel* _panel;
	
	id <SelectionSizeDialogControllerDelegate> _delegate;
	
	NSInteger _windowLevel;
}
@property (nonatomic, assign) id <SelectionSizeDialogControllerDelegate> delegate;

- (void)showWithSize:(NSSize)size;
- (void)hide;
- (IBAction)cancel:(id)sender;
- (IBAction)ok:(id)sender;

- (IBAction)onTextField:(id)sender;

- (void)setWindowLevel:(NSInteger)level;

@end
