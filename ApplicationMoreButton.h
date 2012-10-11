//
//  ApplicatinMoreButton.h
//  SimpleCap
//
//  Created by - on 10/05/03.
//  Copyright 2010 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ApplicationMoreButton : NSView {

	NSImage* _image1;	// for checkboard
	NSImage* _image2;	// for white
	NSImage* _image3;	// for black
	
	id target;
	SEL action;
}

@property (assign) id target;
@property (assign) SEL action;
@end
