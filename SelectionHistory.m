//
//  SelectionHistory.m
//  SimpleCap
//
//  Created by - on 08/10/25.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "SelectionHistory.h"
#import "UserDefaults.h"

#define MAX_HISTORY	  10


#pragma mark -
@implementation SelectionHistoryEntry
@synthesize rect = _rect;
@synthesize date = _date;
@synthesize filePath = _filePath;

- (id)init
{
	if (self = [super init]) {
		_rect = NSZeroRect;
		self.date = [NSDate date];
		_filePath = nil;
	}
	return self;
}

// for tableview
- (CGFloat)width
{
	return _rect.size.width;
}

- (CGFloat)height
{
	return _rect.size.height;
}
- (CGFloat)x
{
	return _rect.origin.x;	
}
- (CGFloat)y
{
	return _rect.origin.y;
}

- (NSString*)filename
{
	NSString* filename = [self.filePath lastPathComponent];
	if (filename == nil || [filename length] == 0) {
		filename = NSLocalizedString(@"SelectionHistoryNonFilename", @"");		
	}
	return filename;
}

- (void) dealloc
{
	self.date = nil;
	self.filePath = nil;
	[super dealloc];
}


@end


/////////////////////////////////////////////////////////////
#pragma mark -
@implementation SelectionHistory
/////////////////////////////////////////////////////////////
@synthesize countForFiltering = _countForFiltering;
@synthesize historyArray = _historyArray;

static SelectionHistory* selectionHistory_;

+ (SelectionHistory*)sharedSelectionHistory
{
	if (selectionHistory_ == nil) {
		selectionHistory_ = [[SelectionHistory alloc] init];
	}
	return selectionHistory_;
}

- (void)clearCaches
{
	if (_cachedArrayOrderBySize) {
		[_cachedArrayOrderBySize release];
		_cachedArrayOrderBySize = nil;
	}

	if (_cachedArrayOrderBySizeDesc) {
		[_cachedArrayOrderBySizeDesc release];
		_cachedArrayOrderBySizeDesc = nil;
	}
}

- (void)load
{
	NSArray* array = [UserDefaults valueForKey:UDKEY_SELECTION_HISTORY];
	for (NSDictionary* dict in array) {
		SelectionHistoryEntry* entry = [[[SelectionHistoryEntry alloc] init] autorelease];
		entry.rect = NSRectFromString([dict objectForKey:@"rect"]);
		entry.date = [dict objectForKey:@"date"];
		entry.filePath = [dict objectForKey:@"filePath"];
		[_historyArray addObject:entry];
	}
	[self clearCaches];
}

- (void)save
{
	NSMutableArray* array = [NSMutableArray array];
	for (SelectionHistoryEntry* entry in _historyArray) {
		NSMutableDictionary* dict = [NSMutableDictionary dictionary];
		[dict setObject:NSStringFromRect(entry.rect) forKey:@"rect"];
		[dict setObject:entry.date forKey:@"date"];
		[dict setObject:entry.filePath forKey:@"filePath"];
		[array addObject:dict];
	}
	[UserDefaults setValue:array forKey:UDKEY_SELECTION_HISTORY];
	[UserDefaults save];
}


- (id)init
{
	self = [super init];
	if (self) {
		_historyArray = [[NSMutableArray alloc] init];
		_countForFiltering = 1;
		[self load];
	}
	return self;
}

- (void) dealloc
{
	[_historyArray release];
	[_cachedArrayOrderBySize release];
	[_cachedArrayOrderBySizeDesc release];
	[super dealloc];
}


- (void)addHistoryRect:(NSRect)rect filePath:(NSString*)filePath
{
	if (filePath == nil) {
		filePath = @"";
	}
	
	SelectionHistoryEntry* entry = [[[SelectionHistoryEntry alloc] init] autorelease];
	entry.rect = rect;
	entry.filePath = filePath;
	[_historyArray addObject:entry];
	
	while ([_historyArray count] >
		[[UserDefaults valueForKey:UDKEY_SELECTION_HISTORY_MAX] intValue]) {
		[_historyArray removeObjectAtIndex:0];
	}

	[self save];
	[self clearCaches];
}

- (void)clearAll
{
	[_historyArray removeAllObjects];
	[self save];
	[self clearCaches];
}

NSInteger sizeSort(id obj1, id obj2, void* context) {
	
	NSRect rect1 = [obj1 rect];
	NSRect rect2 = [obj2 rect];
	CGFloat area1 = rect1.size.width * rect1.size.height;
	CGFloat area2 = rect2.size.width * rect2.size.height;
	if (area1 < area2) {
		return NSOrderedAscending;
	} else if (area1 > area2) {
		return NSOrderedDescending;
	} else {
		CGFloat len1 = rect1.origin.x*rect1.origin.x + rect1.origin.y*rect1.origin.y;
		CGFloat len2 = rect2.origin.x*rect2.origin.x + rect2.origin.y*rect2.origin.y;
		if (len1 < len2) {
			return NSOrderedAscending;
		} else if (len1 > len2) {
			return NSOrderedDescending;
		} else {
			return NSOrderedSame;
		}
	}
}

- (NSMutableArray*)mutableArray
{
	return _historyArray;
}

- (NSArray*)arrayOrderBySize
{
	return _historyArray;
	/*
	if (!_cachedArrayOrderBySize) {
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"count >= %d", self.countForFiltering];
		_cachedArrayOrderBySize = [[[_historyArray filteredArrayUsingPredicate:predicate]
									sortedArrayUsingFunction:sizeSort
										   context:NULL] retain];
	}
	return _cachedArrayOrderBySize;
	  */
	  
}

- (NSArray*)arrayOrderBySizeDesc
{
	return _historyArray;
	/*
	if (!_cachedArrayOrderBySizeDesc) {
		NSMutableArray* array = [NSMutableArray arrayWithCapacity:[_historyArray count]];
		for (id value in [[self arrayOrderBySize] reverseObjectEnumerator]) {
			[array addObject:value];
		}
		_cachedArrayOrderBySizeDesc = [array retain];
	}
	return _cachedArrayOrderBySizeDesc;
	 */
}

- (SelectionHistoryEntry*)entryAtIndex:(NSInteger)index
{
	if (index >=0 && index < [_historyArray count]) {
		return [_historyArray objectAtIndex:index];
	} else {
		return nil;
	}
}

#pragma mark -
#pragma mark Services for UserDefaults
+ (NSData*)archivedDefaultSortDescriptors
{
	NSValueTransformer* transformer = [NSValueTransformer valueTransformerForName:NSUnarchiveFromDataTransformerName];
	NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
	NSData* sortData =[transformer reverseTransformedValue:[NSArray arrayWithObject:sortDescriptor]];
	return sortData;
}

@end

