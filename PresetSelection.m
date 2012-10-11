//
//  PresetSelection.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/20.
//  Copyright 2010 . All rights reserved.
//

#import "PresetSelection.h"
#import "UserDefaults.h"

#pragma mark -
@implementation PresetSelectionEntry

@synthesize rect = _rect;
@synthesize title = _title;

#pragma mark -
#pragma mark Initialization and deallocation
- (id) init
{
	self = [super init];
	if (self != nil) {
		_rect = NSZeroRect;
		_title = nil;
	}
	return self;
}

- (id)initWithDictionaryPresentation:(NSDictionary*)dictionary
{
	self = [super init];
	if (self != nil) {
		_rect = NSRectFromString([dictionary objectForKey:PRESET_SELECTION_KEY_RECT]);
		_title = [[dictionary objectForKey:PRESET_SELECTION_KEY_TITLE] copy];
	}
	return self;
}

- (id)initWithRect:(NSRect)rect title:(NSString*)title
{
	if (self = [super init]) {
		_rect = rect;
		_title = [title copy];
	}
	return self;
}

- (void) dealloc
{
	[_title release];
	[super dealloc];
}


#pragma mark -
#pragma mark Accessors

- (CGFloat)width
{
	return _rect.size.width;
}
- (CGFloat)height
{
	return _rect.size.height;
}

- (void)setWidth:(CGFloat)width
{
	_rect.size.width = width;
}

- (void)setHeight:(CGFloat)height
{
	_rect.size.height = height;
}

#pragma mark -
#pragma mark Services
- (NSDictionary*)directoryPresentation
{
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:2];
	[dict setObject:NSStringFromRect(_rect) forKey:PRESET_SELECTION_KEY_RECT];
	[dict setObject:_title forKey:PRESET_SELECTION_KEY_TITLE];
	return dict;
}


@end


#pragma mark -
@implementation PresetSelection

@synthesize list = _list;

- (id) init
{
	self = [super init];
	if (self != nil) {
		_list = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) dealloc
{
	[_list release];
	[super dealloc];
}


- (PresetSelectionEntry*)entryAtIndex:(NSInteger)index
{
	if (index >=0 && index < [self.list count]) {
		return [self.list objectAtIndex:index];
	} else {
		return nil;
	}
}

#pragma mark -
#pragma mark Save and load
- (void)save
{
	NSMutableArray* list = [NSMutableArray arrayWithCapacity:[self.list count]];
	for (PresetSelectionEntry* entry in self.list) {		
		[list addObject:[entry directoryPresentation]];
	}

	[UserDefaults setValue:list forKey:UDKEY_PRESET_SELECTIONS];
	[UserDefaults save];
}

- (void)load
{
	[self.list removeAllObjects];
	PresetSelectionEntry* entry;

	NSArray* list = [UserDefaults valueForKey:UDKEY_PRESET_SELECTIONS];
	for (NSDictionary* dict in list) {
		entry = [[[PresetSelectionEntry alloc] initWithDictionaryPresentation:dict] autorelease];
		[self.list addObject:entry];
	}
}

- (BOOL)migrateOldDefaults
{
	[self.list removeAllObjects];

	NSArray* widthList = [NSArray arrayWithObjects:
						  UDKEY_SELECTION_WIDTH1,
						  UDKEY_SELECTION_WIDTH2,
						  UDKEY_SELECTION_WIDTH3,
						  UDKEY_SELECTION_WIDTH4,
						  UDKEY_SELECTION_WIDTH5,
						  nil];
	NSArray* heightList = [NSArray arrayWithObjects:
						   UDKEY_SELECTION_HEIGHT1,
						   UDKEY_SELECTION_HEIGHT2,
						   UDKEY_SELECTION_HEIGHT3,
						   UDKEY_SELECTION_HEIGHT4,
						   UDKEY_SELECTION_HEIGHT5,
						   nil];
	NSArray* titleList = [NSArray arrayWithObjects:
						  UDKEY_SELECTION_NAME1,
						  UDKEY_SELECTION_NAME2,
						  UDKEY_SELECTION_NAME3,
						  UDKEY_SELECTION_NAME4,
						  UDKEY_SELECTION_NAME5,
						  nil];
	BOOL is_migrated = NO;
	NSInteger i;
	for (i=0; i < [widthList count]; i++) {
		NSString* widthKey  = [widthList  objectAtIndex:i];
		NSString* heightKey = [heightList objectAtIndex:i];
		NSString* titleKey  = [titleList  objectAtIndex:i];

		if ([UserDefaults valueForKey:widthKey]) {
			NSRect rect = NSZeroRect;
			rect.size.width  = [[UserDefaults valueForKey:widthKey]  floatValue];
			rect.size.height = [[UserDefaults valueForKey:heightKey] floatValue];
			NSString* title = [UserDefaults valueForKey:titleKey];
			PresetSelectionEntry* entry = [[[PresetSelectionEntry alloc]
											initWithRect:rect title:title] autorelease];
			[self.list addObject:entry];
			[UserDefaults removeObjectForKey:widthKey];
			[UserDefaults removeObjectForKey:heightKey];
			[UserDefaults removeObjectForKey:titleKey];
			is_migrated = YES;
		}		
	}
	if (is_migrated) {
		[self save];
	}
	
	return is_migrated;
}

#pragma mark -
#pragma mark Services for UserDefaults
+ (NSArray*)sampleListForPrefereces
{
	NSMutableArray* list = [NSMutableArray array];
	PresetSelectionEntry* entry;
	
	entry = [[[PresetSelectionEntry alloc] init] autorelease];
	entry.rect = NSMakeRect(0, 0, 100, 100);
	entry.title = @"preset 1";
	[list addObject:[entry directoryPresentation]];
	
	entry = [[[PresetSelectionEntry alloc] init] autorelease];
	entry.rect = NSMakeRect(0, 0, 200, 200);
	entry.title = @"preset 2";
	[list addObject:[entry directoryPresentation]];
	
	entry = [[[PresetSelectionEntry alloc] init] autorelease];
	entry.rect = NSMakeRect(0, 0, 300, 300);
	entry.title = @"preset 3";
	[list addObject:[entry directoryPresentation]];
	
	entry = [[[PresetSelectionEntry alloc] init] autorelease];
	entry.rect = NSMakeRect(0, 0, 400, 400);
	entry.title = @"preset 4";
	[list addObject:[entry directoryPresentation]];
	
	return list;
}

+ (NSData*)archivedDefaultSortDescriptors
{
	NSValueTransformer* transformer = [NSValueTransformer valueTransformerForName:NSUnarchiveFromDataTransformerName];
	NSSortDescriptor* sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES] autorelease];
	NSData* sortData =[transformer reverseTransformedValue:[NSArray arrayWithObject:sortDescriptor]];
	return sortData;
}


@end
