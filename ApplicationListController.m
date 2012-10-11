//
//  ApplicationListController.m
//  SimpleCap
//
//  Created by - on 10/04/27.
//  Copyright 2010 Hiroshi Hashiguchi. All rights reserved.
//

#import "ApplicationListController.h"
#import "ApplicationEntry.h"
#import "ApplicationCell.h"
#import "UserDefaults.h"

#define AppListTableViewDataType @"AppListTableViewDataType"

@implementation ApplicationListController
@synthesize applicationList = applicationList_;

#pragma mark -
#pragma mark Initialization & Deallocation
- (id) init
{
	self = [super init];
	if (self != nil) {
		self.applicationList = [NSMutableArray array];
		
	}
	return self;
}
- (void) dealloc
{
	self.applicationList = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Utilities
- (void)save
{
	NSMutableArray* pathList = [NSMutableArray array];
	for (ApplicationEntry* entry in applicationList_) {
		[pathList addObject:entry.path];
	}
	[UserDefaults setValue:pathList forKey:UDKEY_APPLICATION_LIST];
	[UserDefaults save];
}

- (void)rearrangeList
{
	[arrayController_ rearrangeObjects];
	[self save];
}

- (BOOL)migrateOldDefaults
{
	NSString* value = nil;
	NSArray* array = [NSArray arrayWithObjects:
					  UDKEY_APPLICATION1,
					  UDKEY_APPLICATION2,
					  UDKEY_APPLICATION3,
					  UDKEY_APPLICATION4,
					  UDKEY_APPLICATION5,
					  nil];
	BOOL is_migrated = NO;
	for (NSString* key in array) {
		if (value = [UserDefaults valueForKey:key]) {
			[applicationList_ addObject:[[[ApplicationEntry alloc] initWithPath:value] autorelease]];
			[UserDefaults removeObjectForKey:key];
			is_migrated = YES;
		}
	}
	if (is_migrated) {
		[self save];
	}
	
	return is_migrated;
}

- (void)awakeFromNib
{
	[tableView_ registerForDraggedTypes:
	 [NSArray arrayWithObjects:
	  NSFilenamesPboardType, AppListTableViewDataType, nil]];
	
	[tableColumn_ setDataCell:[[[ApplicationCell alloc] init] autorelease]];
	
	
	if (![self migrateOldDefaults]) {	
		NSArray* pathList = [UserDefaults valueForKey:UDKEY_APPLICATION_LIST];
		for (NSString* path in pathList) {
			[applicationList_ addObject:[[[ApplicationEntry alloc] initWithPath:path] autorelease]];
		}
	}

	[arrayController_ rearrangeObjects];
	
}


#pragma mark -
#pragma mark NSTableViewDataSource Protocol
- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:rowIndexes];
    [pboard declareTypes:[NSArray arrayWithObject:AppListTableViewDataType] owner:self];
    [pboard setData:data forType:AppListTableViewDataType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)aTableView validateDrop:(id < NSDraggingInfo >)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)operation
{
	[aTableView setDropRow:row dropOperation:NSTableViewDropAbove];
	
	if ([info draggingSource] == tableView_) {
		return NSDragOperationMove;
	} 
	return NSDragOperationEvery;
}

- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
			  row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    NSPasteboard* pboard = [info draggingPasteboard];	
	NSArray* pboardTypes = [pboard types];
	
	if ([pboardTypes containsObject:AppListTableViewDataType]) {
		
		NSData* data = [pboard dataForType:AppListTableViewDataType];
		
		NSIndexSet *rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		
		NSArray* srcArray = [applicationList_ objectsAtIndexes:rowIndexes];
		NSUInteger srcCount = [srcArray count];
		
		if ([rowIndexes firstIndex] < row) {
			row = row - srcCount;
		}
		NSIndexSet* newIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(row, srcCount)];
		
		[applicationList_ removeObjectsAtIndexes:rowIndexes];
		[applicationList_ insertObjects:srcArray atIndexes:newIndexes];
		[self rearrangeList];
		
		
		//		[arrayController_ removeObjectsAtArrangedObjectIndexes:rowIndexes];
		//		[arrayController_ insertObjects:srcArray atArrangedObjectIndexes:newIndexes];
		return YES;
		
	} else if ([pboardTypes containsObject:NSFilenamesPboardType]) {
		NSArray*filenames = [pboard propertyListForType:NSFilenamesPboardType];
		
		for (NSString* filename in filenames) {
			ApplicationEntry* entry = [[[ApplicationEntry alloc] initWithPath:filename] autorelease];
			
			[applicationList_ insertObject:entry atIndex:row];
			//			[arrayController_ insertObject:entry atArrangedObjectIndex:row];
		}
		[self rearrangeList];
		return YES;
	} else {
		return NO;
	}
}

#pragma mark -
#pragma mark Application List
- (IBAction)addApplication:(id)sender
{
	NSString* path = @"/Applications";
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanCreateDirectories:NO];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setDirectory:path];
	
	int result = [openPanel runModalForDirectory:path
											file:nil
										   types:nil];
	
	if (result == NSOKButton) {
		for (NSString* filename in [openPanel filenames]) {
			ApplicationEntry* entry = [[[ApplicationEntry alloc] initWithPath:filename] autorelease];
			
			[applicationList_ addObject:entry];
		}
		[self rearrangeList];
	}
}

- (IBAction)removeApplication:(id)sender
{
	[arrayController_ remove:self];
	[self rearrangeList];
}

@end
