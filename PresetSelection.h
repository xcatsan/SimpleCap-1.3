//
//  PresetSelection.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/20.
//  Copyright 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define PRESET_SELECTION_KEY_RECT	@"PresetSelectionKeyRect"
#define PRESET_SELECTION_KEY_TITLE	@"PresetSelectionKeyTitle"

@interface PresetSelectionEntry : NSObject
{
	NSString* _title;
	NSRect _rect;
}

@property (nonatomic, assign) NSRect rect;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

- (id)initWithRect:(NSRect)rect title:(NSString*)title;
- (id)initWithDictionaryPresentation:(NSDictionary*)dictionary;
- (NSDictionary*)directoryPresentation;

@end


@interface PresetSelection : NSObject {

	NSMutableArray* _list;
}

@property (nonatomic, retain, readonly) NSMutableArray* list;

- (PresetSelectionEntry*)entryAtIndex:(NSInteger)index;

- (void)save;
- (void)load;
- (BOOL)migrateOldDefaults;

#pragma mark -
#pragma mark Services for UserDefaults
+ (NSArray*)sampleListForPrefereces;
+ (NSData*)archivedDefaultSortDescriptors;


@end
