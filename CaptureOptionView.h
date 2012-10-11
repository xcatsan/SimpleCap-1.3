//
//  CaptureOptionView.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 11/01/13.
//  Copyright 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	kCaptureOptionNone,
	kCaptureOptionFlashSelection,
	kCaptureOptionFlashImage
} CaptureOptionStatus;


@interface CaptureOptionView : NSView {

	CaptureOptionStatus status_;
	NSImage* image_;
	NSTimer* timer_;
	
	CGFloat decrementValue_;
	CGFloat startValue_;
}
@property (nonatomic, retain) NSImage* image;

- (void)showImage:(NSImage*)image frame:(NSRect)frame;
- (void)flashInframe:(NSRect)frame;

@end
