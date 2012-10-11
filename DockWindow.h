//
//  DockWindow.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/16.
//  Copyright 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DockWindow : NSObject {
	
	NSMutableArray* _id_list;
}

+ (DockWindow*)sharedDockWindow;
- (NSArray*)CGWindowIDlist;
- (void)update;
- (CGImageRef)cgimageInRect:(CGRect)cgrect;

@end
