//
//  MenubarWindow.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/18.
//  Copyright 2010 . All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MenubarWindow : NSObject {

	NSMutableArray* _id_list;
}

+ (MenubarWindow*)sharedMenubarWindow;
- (NSArray*)CGWindowIDlist;
- (void)update;
- (CGImageRef)cgimageInRect:(CGRect)cgrect;

@end
