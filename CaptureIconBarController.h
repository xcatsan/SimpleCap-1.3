//
//  CaptureIconBarController.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/18.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
	CIB_TAG_WINDOWS,
	CIB_TAG_SELECTION,
	CIB_TAG_MENU,
	CIB_TAG_SCREEN,
	CIB_TAG_APPLICATION,
	CIB_TAG_WIDGETS
};
@class AppController;
@class ApplicationMenu;
@class ThinButtonBar;
@interface CaptureIconBarController : NSObject {

	ThinButtonBar *_button_bar;
	AppController* _app_controller;
	
	NSMenu* _capture_app_menu;
}

- (id)initWithSuperView:(NSView*)superView appController:(AppController*)appController;
- (void)setSuperViewFrame:(NSRect)frame;
- (void)setFlipped;
- (void)setHidden:(BOOL)hidden;
@end
