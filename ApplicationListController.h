//
//  ApplicationListController.h
//  SimpleCap
//
//  Created by - on 10/04/27.
//  Copyright 2010 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ApplicationListController : NSObject {

	IBOutlet NSTableView* tableView_;
	IBOutlet NSArrayController* arrayController_;
	IBOutlet NSTableColumn* tableColumn_;
	
	NSMutableArray* applicationList_;
}
@property (retain) NSMutableArray* applicationList;
- (IBAction)addApplication:(id)sender;
- (IBAction)removeApplication:(id)sender;



@end
