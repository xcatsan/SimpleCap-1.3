//
//  SelectionHistory.h
//  SimpleCap
//
//  Created by - on 08/10/25.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SelectionHistoryEntry : NSObject
{
	NSRect _rect;
	NSDate* _date;
	NSString* _filePath;
}
@property (nonatomic, assign) NSRect rect;
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, copy) NSString* filePath;

// for tableview
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)width;
- (CGFloat)height;

@end


@interface SelectionHistory : NSObject {

	NSMutableArray* _historyArray;
	
	NSArray* _cachedArrayOrderBySize;
	NSArray* _cachedArrayOrderBySizeDesc;
	
	NSInteger _countForFiltering;
}
@property (nonatomic, assign) NSInteger countForFiltering;
@property (nonatomic, assign, readonly) NSMutableArray* historyArray;

+ (SelectionHistory*)sharedSelectionHistory;
- (void)addHistoryRect:(NSRect)rect filePath:(NSString*)filePath;
- (NSMutableArray*)mutableArray;
- (NSArray*)arrayOrderBySize;
- (NSArray*)arrayOrderBySizeDesc;
- (void)clearAll;
- (SelectionHistoryEntry*)entryAtIndex:(NSInteger)index;

#pragma mark -
#pragma mark Services for UserDefaults
+ (NSData*)archivedDefaultSortDescriptors;

@end
