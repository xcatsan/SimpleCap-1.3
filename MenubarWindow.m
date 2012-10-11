//
//  MenubarWindow.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/18.
//  Copyright 2010 . All rights reserved.
//

#import "MenubarWindow.h"


@implementation MenubarWindow

static MenubarWindow* _menubar_window = nil;

+ (MenubarWindow*)sharedMenubarWindow
{
	if (!_menubar_window) {
		_menubar_window = [[MenubarWindow alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:_menubar_window
												 selector:@selector(screenChanged:)
													 name:NSApplicationDidChangeScreenParametersNotification
												   object:nil];
		[_menubar_window update];
	}
	return _menubar_window;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_id_list release];
	[super dealloc];
}

- (void)update
{
	CFArrayRef ar = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
	CFDictionaryRef window;
	CFIndex i;
	CGWindowID wid;
	
	[_id_list release];
	_id_list = [[NSMutableArray alloc] init];
	
	for (i=0; i < CFArrayGetCount(ar); i++) {
		window = CFArrayGetValueAtIndex(ar, i);
		int layer;
		CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowLayer),
						 kCFNumberIntType, &layer);

		if (layer == kCGStatusWindowLevel) {
 			CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowNumber),
							 kCGWindowIDCFNumberType, &wid);
			[_id_list addObject:[NSNumber numberWithUnsignedInt:wid]];

		} else if (layer == kCGMainMenuWindowLevel) {
 			CFNumberGetValue(CFDictionaryGetValue(window, kCGWindowNumber),
							 kCGWindowIDCFNumberType, &wid);
			[_id_list addObject:[NSNumber numberWithUnsignedInt:wid]];
			
		}
	}
}

- (NSArray*)CGWindowIDlist
{
	return _id_list;
}

- (void)screenChanged:(NSNotification *)notification
{
	[self update];
}

- (CGImageRef)cgimageInRect:(CGRect)cgrect
{
	CGWindowID *windowIDs = calloc([_id_list count], sizeof(CGWindowID));
	
	int widx = 0;
	for (NSNumber* num in _id_list) {
		windowIDs[widx++] = [num unsignedIntValue];
	} 
	
	CFArrayRef windowIDsArray = CFArrayCreate(kCFAllocatorDefault, (const void**)windowIDs, widx, NULL);
	
	CGImageRef cgimage = CGWindowListCreateImageFromArray(
														  cgrect, windowIDsArray, kCGWindowImageDefault);
	return cgimage;
	
}

@end
