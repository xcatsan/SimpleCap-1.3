//
//  UserDefaults.m
//  SimpleCap
//
//  Created by - on 08/09/14.
//  Copyright 2008 Hiroshi Hashiguchi. All rights reserved.
//

#import "UserDefaults.h"
#import "Hotkey.h"
#import "PresetSelection.h"
#import "SelectionHistory.h"

#define DEFAULT_IMAGE_FOLDER	@"SimpleCap Images"

@implementation UserDefaults
//
// main
//
+ (void)setup
{
	// basic setting
	NSString* path = [NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	path = [path stringByAppendingPathComponent:DEFAULT_IMAGE_FOLDER];
	
	NSNumber* n0 = [NSNumber numberWithInt:0];
	NSNumber* n1 = [NSNumber numberWithInt:1];

	NSArray* emptyArray = [NSArray array];

	NSDictionary *initial_values = [NSDictionary dictionaryWithObjectsAndKeys:
									n0,		UDKEY_IMAGE_FORMAT,
									path,	UDKEY_IMAGE_LOCATION,
//									n0,		UDKEY_PLAY_SOUND,
									n1,		UDKEY_MOUSE_CURSOR,
									n1,		UDKEY_WINDOW_SHADOW,
									n0,		UDKEY_BACKGROUND,
									n0,		UDKEY_SELECTION_WHITE_FRAME,
									n0,		UDKEY_SELECTION_SHADOW,
									n0,		UDKEY_SELECTION_ROUND_RECT,
									n0,		UDKEY_SELECTION_EXCLUDE_ICONS,
									[NSNumber numberWithInt:DEFAULT_TIMER_TIMES], UDKEY_TIMER_SECOND,
									n0,		UDKEY_CURSOR_METHOD,
//									n1,		UDKEY_USE_SIMPLEVIEWER,
									n0,		UDKEY_SCREEN_EXCLUDE_ICONS,
									n0,		UDKEY_MENU_ACTUAL_WIDTH,
									[NSNumber numberWithInt:20],
										UDKEY_SELECTION_HISTORY_MAX,
									n0,		UDKEY_VIEWER_BACKGROUND,
									n0,		UDKEY_VIEWER_IMAGEBOUNDS,
									n1,		UDKEY_VIEWER_ALWAYS_ON_TOP,
									n1,		UDKEY_VIEWER_SHOW_AFTER_CAPTURED,
									[Hotkey numberValueWithKeycode:29 modifier:(cmdKey | optionKey)],UDKEY_HOT_KEY,
									n1,		UDKEY_HOT_KEY_ENABLE,
									emptyArray, UDKEY_APPLICATION_LIST,
									n1,		UDKEY_SELECTIONLIST_SHOW,
									[PresetSelection sampleListForPrefereces], UDKEY_PRESET_SELECTIONS,
									[PresetSelection archivedDefaultSortDescriptors], UDKEY_SELECTIONLIST_SORT_PRESET,
									[SelectionHistory archivedDefaultSortDescriptors], UDKEY_SELECTIONLIST_SORT_HISTORY,
									@"Preset", UDKEY_SELECTIONLIST_TAB_IDENTIFIER,
									nil];
	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:initial_values];
}

+ (NSUserDefaults*)values
{
	return [[NSUserDefaultsController sharedUserDefaultsController] values];
}

+ (id)valueForKey:(NSString*)key
{
	return [[self values] valueForKey:key];
}

+ (void)setValue:(id)value forKey:(NSString*)key
{
	[[self values] setValue:value forKey:key];
}
+ (void)removeObjectForKey:(NSString*)key
{
	[self setValue:nil forKey:key];
}

+ (void)save
{
	[(NSUserDefaultsController*)[NSUserDefaultsController sharedUserDefaultsController] save:self];
}

+ (void)resetValueForKey:(NSString*)key
{
	NSDictionary* initial_values = [[NSUserDefaultsController sharedUserDefaultsController] initialValues];
	id initial_value = [initial_values valueForKey:key];
	[self setValue:initial_value forKey:key];
	[self save];
}

+ (void)addObserver:(id)observer forKey:(NSString*)key
{
	[[NSUserDefaultsController sharedUserDefaultsController]
	 addObserver:observer
	 forKeyPath:[@"values." stringByAppendingString:key]
	 options:NSKeyValueObservingOptionNew
	 context:nil];
}
+ (void)removeObserver:(id)observer forKey:(NSString*)key
{
	[[NSUserDefaultsController sharedUserDefaultsController]
	 removeObserver:observer
	 forKeyPath:[@"values." stringByAppendingString:key]];	
}

@end
