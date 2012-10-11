//
//  DockWindow.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/16.
//  Copyright 2010 . All rights reserved.
//

#import "DockWindow.h"


@implementation DockWindow

static DockWindow* _dock_window = nil;

+ (DockWindow*)sharedDockWindow
{
	if (!_dock_window) {
		_dock_window = [[DockWindow alloc] init];
		[[NSNotificationCenter defaultCenter] addObserver:_dock_window
												 selector:@selector(screenChanged:)
													 name:NSApplicationDidChangeScreenParametersNotification
												   object:nil];
		[_dock_window update];
	}
	return _dock_window;
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
		NSString* owner_name = (NSString*)CFDictionaryGetValue(window, kCGWindowOwnerName);
		if ([owner_name isEqualToString:@"Dock"]) {
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
