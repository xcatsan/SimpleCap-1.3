//
//  SelectionListViewController.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/11/20.
//  Copyright 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SelectionListViewController;
@protocol SelectionListViewControllerDelegate

- (void)didSelectSelectionListViewController:(SelectionListViewController*)controller rect:(NSRect)rect;
- (void)willCloseSelectionListViewController:(SelectionListViewController*)controller;
- (NSRect)currentSelectionRect;
- (void)showImageFilePath:(NSString*)filePath;
- (void)flashSelection;

@end

@class PresetSelection;
@class SelectionHistory;
@class SelectionListPanel;
@class ThinButtonBar;
@class UndoableArrayController;
@interface SelectionListViewController : NSObject {

	IBOutlet SelectionListPanel* _panel;
	IBOutlet NSTabView* _tabView;
	IBOutlet NSTableView* _tableView1;
	IBOutlet NSTableView* _tableView2;

	IBOutlet UndoableArrayController* _userArrayController;
	IBOutlet NSArrayController* _historyArrayController;

	id <SelectionListViewControllerDelegate> _delegate;
	
	NSInteger _windowLevel;
	
	PresetSelection* _presetSelection;
	SelectionHistory* _selectionHistory;
	
	ThinButtonBar* _presetButtonBar;
	
	IBOutlet NSBox* _buttonBox;
    
    NSWindow* _parentWindow;
}

@property (nonatomic, assign) id <SelectionListViewControllerDelegate> delegate;
@property (nonatomic, assign, readonly) PresetSelection* presetSelection;
@property (nonatomic, assign, readonly) SelectionHistory* selectionHistory;

@property (nonatomic, retain) NSWindow* parentWindow;

- (void)show;
- (void)hide;
- (void)hideTemporary;
- (void)showTemporary;
- (void)showIfShowingStatus;

- (void)movePreviousTab;
- (void)moveNextTab;
- (void)switchTab;
- (void)switchNextTab;
- (void)switchPreviousTab;

- (void)setWindowLevel:(NSInteger)level;
- (void)addSelection:(id)sender;
- (void)removeSelection:(id)sender;
- (BOOL)isVisible;

- (void)rearrangeHistoryList;


// not used at 2010-12-18
- (IBAction)selectPresetTab:(id)sedner;
- (IBAction)selectHistoryTab:(id)sedner;


@end
