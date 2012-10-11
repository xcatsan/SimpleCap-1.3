//
//  ButtonPallete.h
//  MatrixSample
//
//  Created by - on 09/12/08.
//  Copyright 2009 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ApplicationButtonMatrix;
@class ApplicationMoreButton;

@interface ApplicationButtonPallete : NSObject {

	ApplicationButtonMatrix* matrix;
	NSView* contentView;
	NSRect display_frame;
	ApplicationMoreButton* menu_button;

	id target;
	SEL action;
	SEL menuAction;
	
	NSArrayController* arrayController;
	int number_of_displayed_icons;
}
@property (retain) id target;
@property (assign) SEL action;
@property (assign) SEL menuAction;
@property (retain) NSArrayController* arrayController;

-(void)addButtonWithPath:(NSString*)path;

-(void)addToView:(NSView*)view;
-(void)setDisplayFrame:(NSRect)frame;
-(void)updateLayout;

@end
