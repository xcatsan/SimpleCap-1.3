//
//  SelectionListViewController.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/20.
//  Copyright 2010 . All rights reserved.
//

#import "SelectionListViewController.h"
#import "PresetSelection.h"
#import "SelectionHistory.h"
#import "ThinButtonBar.h"
#import "UserDefaults.h"
#import "SelectionListPanel.h"
#import "UndoableArrayController.h"
#import "SelectionListHeaderCell.h"
#import "SelectionListCornerView.h"
#import "SelectionListHeaderCell.h"

enum {
	SLV_TAG_PLUS,
	SLV_TAG_MINUS,
	SLV_TAG_UNDO,
	SLV_TAG_REDO
};

@interface SelectionListViewController()
- (void)_tableView:(NSTableView *)tableView didSetSortedColumn:(NSTableColumn *)tableColumn;
@end

@implementation SelectionListViewController

@synthesize delegate = _delegate;
@synthesize presetSelection = _presetSelection;
@synthesize selectionHistory = _selectionHistory;
@synthesize parentWindow = _parentWindow;

#pragma mark -
#pragma mark Utilities for private
- (void)_setSelectionAtRow:(NSInteger)row inTableView:(NSTableView*)tableView
{
	NSRect rect;
	if (tableView == _tableView1) {
		PresetSelectionEntry* entry = [[_userArrayController arrangedObjects] objectAtIndex:row];
		rect = [_delegate currentSelectionRect];
		rect.size = entry.rect.size;
		[_delegate didSelectSelectionListViewController:self rect:rect];
		[_delegate flashSelection];
	} else if (tableView == _tableView2) {
		SelectionHistoryEntry* entry = [[_historyArrayController arrangedObjects] objectAtIndex:row];
		rect = entry.rect;
		[_delegate didSelectSelectionListViewController:self rect:rect];
		if (entry.filePath != nil && [entry.filePath length] > 0) {
			if ([[NSFileManager defaultManager] fileExistsAtPath:entry.filePath]) {
				[_delegate showImageFilePath:entry.filePath];
			} else {
				[_delegate flashSelection];
			}
		} else {
			[_delegate flashSelection];
		}
	}
}

- (void)_setSelectedRowSizeToSelection
{
	NSArray* selectedObjects = [_userArrayController selectedObjects];
	if ([selectedObjects count] > 0) {
		NSRect rect = [_delegate currentSelectionRect];
		PresetSelectionEntry* entry = [selectedObjects objectAtIndex:0];
		rect.size = entry.rect.size;
		[_delegate didSelectSelectionListViewController:self rect:rect];		
	}
}

- (void)_setPushedStateAtTag:(NSInteger)tag
{
	for (NSButton* button in [[_buttonBox contentView] subviews]) {
		if ([button tag] == tag) {
			[button setState:NSOnState];
		} else {
			[button setState:NSOffState];
		}
	}
}


- (void)_didSelectTab
{
	NSString* tabIdentifier = [[_tabView selectedTabViewItem] identifier];
	if ([tabIdentifier isEqualToString:@"Preset"]) {
		[_presetButtonBar show];
		[self _setPushedStateAtTag:0];
	} else {		
		[_presetButtonBar hide];
		[self _setPushedStateAtTag:1];
	}	
}

#pragma mark -
#pragma mark Control panel
- (void)_loadPanel
{
	NSNib* nib = [[NSNib alloc] initWithNibNamed:@"SelectionList"
										  bundle:nil];
	BOOL result = [nib instantiateNibWithOwner:self
							   topLevelObjects:nil];
	[nib release];
	if (!result) {
		NSLog(@"Loading SelectionList.xib is faield!");
		return;
	}
	
	NSString* frameString = [UserDefaults valueForKey:UDKEY_PRESET_SELECTIONS_PANEL_POSITION];
	if (frameString) {
		[_panel setFrame:NSRectFromString(frameString) display:YES];
	}
	
	[_panel setLevel:_windowLevel];
//	[_panel setBecomesKeyOnlyIfNeeded:YES];
	[_panel setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
//	[_panel setBackgroundColor:[NSColor clearColor]];
	[_panel setOpaque:NO];

	[_tableView1 deselectAll:nil];
	[_tableView2 deselectAll:nil];
	
	_presetButtonBar = [[ThinButtonBar alloc] initWithFrame:NSZeroRect vertical:NO];
	[_presetButtonBar setPosition:SC_BUTTON_POSITION_LEFT_BOTTOM];
	
	[_presetButtonBar addButtonWithImageResource:@"icon_selection_plus"
							  alterImageResource:@"icon_selection_plus2"
											 tag:SLV_TAG_PLUS
										 tooltip:NSLocalizedString(@"", @"")
										   group:nil
								isActOnMouseDown:NO];
	
	[_presetButtonBar addButtonWithImageResource:@"icon_selection_minus"
							  alterImageResource:@"icon_selection_minus2"
											 tag:SLV_TAG_MINUS
										 tooltip:NSLocalizedString(@"", @"")
										   group:nil
								isActOnMouseDown:NO];
	
	[_presetButtonBar addButtonWithImageResource:@"icon_selection_undo"
							  alterImageResource:@"icon_selection_undo2"
											 tag:SLV_TAG_UNDO
										 tooltip:NSLocalizedString(@"", @"")
										   group:nil
								isActOnMouseDown:NO];
	
	[_presetButtonBar addButtonWithImageResource:@"icon_selection_redo"
							  alterImageResource:@"icon_selection_redo2"
											 tag:SLV_TAG_REDO
										 tooltip:NSLocalizedString(@"", @"")
										   group:nil
								isActOnMouseDown:NO];
	
	[_presetButtonBar setDelegate:self];
	[_presetButtonBar setDrawOffset:NSMakePoint(-3, -26)];
	[_presetButtonBar recalturateFrame];
	[[_panel contentView] addSubview:_presetButtonBar];
	
	[_presetButtonBar show];	
	
	NSString* tabIdentifier = [UserDefaults valueForKey:UDKEY_SELECTIONLIST_TAB_IDENTIFIER];
	[_tabView selectTabViewItemWithIdentifier:tabIdentifier];
	[self _didSelectTab];
	
	for (NSTableColumn* column in [_tableView1 tableColumns]) {
		SelectionListHeaderCell* headerCell =
			[[[SelectionListHeaderCell alloc] initWithCell:[column headerCell]] autorelease];
		[column setHeaderCell:headerCell];
	}
	for (NSTableColumn* column in [_tableView2 tableColumns]) {
		SelectionListHeaderCell* headerCell =
			[[[SelectionListHeaderCell alloc] initWithCell:[column headerCell]] autorelease];
		[column setHeaderCell:headerCell];
	}
	
	
	NSView* orgView = [_tableView1 cornerView];
	SelectionListCornerView* cornerView =
		[[[SelectionListCornerView alloc] initWithFrame:orgView.frame] autorelease];
	[_tableView1 setCornerView:cornerView];
	NSScrollView* scrollView = [_tableView1 enclosingScrollView];
	NSView* contentView = [scrollView contentView];
	[contentView setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didScroll:)
												 name:NSViewBoundsDidChangeNotification
											   object:contentView];

	orgView = [_tableView2 cornerView];
	cornerView =
		[[[SelectionListCornerView alloc] initWithFrame:orgView.frame] autorelease];
	[_tableView2 setCornerView:cornerView];
	scrollView = [_tableView2 enclosingScrollView];
	contentView = [scrollView contentView];
	[contentView setPostsFrameChangedNotifications:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didScroll:)
												 name:NSViewBoundsDidChangeNotification
											   object:contentView];
	
	NSArray* array1 = [_userArrayController sortDescriptors];
	if ([array1 count] > 0) {
		NSSortDescriptor* sd1 = [array1 objectAtIndex:0];
		NSTableColumn* c1 = [_tableView1 tableColumnWithIdentifier:[sd1 key]];
		[self _tableView:_tableView1 didSetSortedColumn:c1];		
	}

	NSArray* array2 = [_historyArrayController sortDescriptors];
	if ([array2 count] > 0) {
		NSSortDescriptor* sd2 = [array2 objectAtIndex:0];
		NSTableColumn* c2 = [_tableView2 tableColumnWithIdentifier:[sd2 key]];
		[self _tableView:_tableView2 didSetSortedColumn:c2];
	}	
}

- (void)showTemporary
{
	if (_panel == nil) {
		[self _loadPanel];
	}

    [_panel orderFront:self];
//	[_panel makeKeyAndOrderFront:self];
//    [_panel orderWindow:NSWindowBelow relativeTo:[self.parentWindow windowNumber]];
//	[NSApp activateIgnoringOtherApps:YES];
}

- (void)hideTemporary
{
	[_panel orderOut:self];	
}

- (void)hide
{
	[self hideTemporary];

	// save status
	[UserDefaults setValue:[NSNumber numberWithBool:NO]
					forKey:UDKEY_SELECTIONLIST_SHOW];
	[UserDefaults save];
}

- (void)show
{
	[self showTemporary];
	
	// save status
	[UserDefaults setValue:[NSNumber numberWithBool:YES]
					forKey:UDKEY_SELECTIONLIST_SHOW];
	[UserDefaults save];	
}

- (void)showIfShowingStatus
{
	if ([[UserDefaults valueForKey:UDKEY_SELECTIONLIST_SHOW] boolValue]) {
		[self showTemporary];
	}	
}

- (void)setWindowLevel:(NSInteger)level
{
	_windowLevel = level;
}


- (BOOL)windowShouldClose:(id)sender
{
	[self hide];
	[_delegate willCloseSelectionListViewController:self];
	return YES;
}

- (BOOL)isVisible
{
	return [_panel isVisible];
}



#pragma mark -
#pragma mark Initialization and deallocation
- (id) init
{
	self = [super init];
	if (self != nil) {
		_presetSelection = [[PresetSelection alloc] init];
		if (![_presetSelection migrateOldDefaults]) {
			[_presetSelection load];
		}
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(editingDidEnd:)
													 name:NSControlTextDidEndEditingNotification object:_tableView1];
		_selectionHistory = [SelectionHistory sharedSelectionHistory];
	}
	return self;
}

- (void) dealloc
{
	[_presetSelection release];
	[super dealloc];
}

#pragma mark -
#pragma mark Management list by event
- (void)addSelection:(id)sender
{
	NSRect rect = [_delegate currentSelectionRect];
	PresetSelectionEntry* entry = [[[PresetSelectionEntry alloc] initWithRect:rect title:@"new selection"] autorelease];
		//	[_userArrayController addObject:entry];
	NSInteger index = [[_userArrayController arrangedObjects] count];
	[_userArrayController insertObject:entry atArrangedObjectIndex:index];
	[_tableView1 editColumn:0
					   row:[_userArrayController selectionIndex]
				 withEvent:nil
					select:YES];
	[_presetSelection save];
}

- (void)removeSelection:(id)sender
{	
	if ([[_userArrayController arrangedObjects] count] == 0) {
		return;
	}
	NSUInteger index = [_userArrayController selectionIndex];

	[_userArrayController removeObjectAtArrangedObjectIndex:index];
	[_presetSelection save];
}


#pragma mark -
#pragma mark NSTableViewDelegate
- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
	[self _setSelectionAtRow:row inTableView:tableView];
	return YES;
}

- (void)_tableView:(NSTableView *)tableView didSetSortedColumn:(NSTableColumn *)tableColumn
{
	
	SelectionListHeaderCell* cell = nil;
	BOOL ascending;
	NSInteger priority;

	for (NSTableColumn* column in [tableView tableColumns]) {

		cell  = (SelectionListHeaderCell*)[column headerCell];

		if (column == tableColumn) {
			if (tableView == _tableView1) {
				ascending = [[[_userArrayController sortDescriptors] objectAtIndex:0] ascending];
			} else {
				ascending = [[[_historyArrayController sortDescriptors] objectAtIndex:0] ascending];
			}
			priority = 0;
		} else {
			priority = 1;
		}

		[cell setSortAscending:ascending priority:priority];
	}
}

- (void)tableView:(NSTableView *)tableView didClickTableColumn:(NSTableColumn *)tableColumn
{	
	[self _tableView:tableView didSetSortedColumn:tableColumn];
	[_panel redraw];
}

#pragma mark -
#pragma mark NSControlTextDidEndEditingNotification 
- (void)editingDidEnd:(NSNotification *)notification
{
	[_presetSelection save];

	NSTableView* tableView = (NSTableView*)[notification object];

	[self _setSelectionAtRow:[tableView selectedRow] inTableView:tableView];
}


#pragma mark -
#pragma mark Buttonbar
-(void)clickedAtTag:(NSNumber*)tag event:(NSEvent*)event
{
	switch ([tag intValue]) {
		case SLV_TAG_PLUS:
			[self addSelection:nil];
			break;
			
		case SLV_TAG_MINUS:
			[self removeSelection:nil];
			break;
	
		case SLV_TAG_UNDO:
			if ([_userArrayController undo]) {
				[self _setSelectedRowSizeToSelection];
			}
			break;
			
		case SLV_TAG_REDO:
			if ([_userArrayController redo]) {
				[self _setSelectedRowSizeToSelection];
			}
			break;			
	}
}

#pragma mark -
#pragma mark NSWindowDelegate
- (void)saveFrame:(NSRect)frame
{
	[UserDefaults setValue:NSStringFromRect(frame)
					forKey:UDKEY_PRESET_SELECTIONS_PANEL_POSITION];
	[UserDefaults save];
}

- (void)windowDidMove:(NSNotification *)notification
{
	SelectionListPanel* panel = [notification object];
	[self saveFrame:panel.frame];
}
- (void)windowDidEndLiveResize:(NSNotification *)notification
{
	SelectionListPanel* panel = [notification object];
	[self saveFrame:panel.frame];
}

- (void)rearrangeHistoryList
{
	[_historyArrayController rearrangeObjects];
}


#pragma mark -
#pragma mark NSTabViewDelegate
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSString* tabIdentifier = [tabViewItem identifier];
	[UserDefaults setValue:tabIdentifier forKey:UDKEY_SELECTIONLIST_TAB_IDENTIFIER];
	[UserDefaults save];
	
	[self _didSelectTab];
	
	[_panel redraw];
}


#pragma mark -
#pragma mark Management of tab buttons
- (IBAction)selectPresetTab:(id)sedner
{
	[_tabView selectTabViewItemAtIndex:0];
}
- (IBAction)selectHistoryTab:(id)sedner
{
	[_tabView selectTabViewItemAtIndex:1];
}


#pragma mark -
#pragma mark Scroll Event
- (void)didScroll:(NSNotification *)notification
{
	[_panel redraw];
}


#pragma mark -
#pragma mark Services
- (BOOL)_moveTabAtIndex:(NSInteger)index
{
	BOOL is_end = NO;
	NSArray* array = [_tabView tabViewItems];
	if (index < 0) {
		index = [array count]-1;
		is_end = YES;
	} else if (index >= [array count]) {
		index = 0;
		is_end = YES;
	}
	[_tabView selectTabViewItemAtIndex:index];
	return is_end;
}

- (void)movePreviousTab
{
	NSInteger index = [_tabView indexOfTabViewItem:
					   [_tabView selectedTabViewItem]];
	[self _moveTabAtIndex:index-1];
}

- (void)moveNextTab
{
	NSInteger index = [_tabView indexOfTabViewItem:
					   [_tabView selectedTabViewItem]];
	[self _moveTabAtIndex:index+1];
}

- (void)switchTab
{
	[self switchNextTab];
}
- (void)switchNextTab
{
	NSInteger index = [_tabView indexOfTabViewItem:
					   [_tabView selectedTabViewItem]];
	BOOL is_end = [self _moveTabAtIndex:index+1];
	if (is_end) {
		[self hide];
	}
}
- (void)switchPreviousTab
{
	NSInteger index = [_tabView indexOfTabViewItem:
					   [_tabView selectedTabViewItem]];
	BOOL is_end = [self _moveTabAtIndex:index-1];
	if (is_end) {
		[self hide];
	}	
}

@end
