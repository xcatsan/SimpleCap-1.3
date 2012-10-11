//
//  SelectionListPanel.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/12/02.
//  Copyright 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SelectionListViewController;
@interface SelectionListPanel : NSPanel {

	IBOutlet SelectionListViewController* _viewController;
}

- (void)redraw;

@end
