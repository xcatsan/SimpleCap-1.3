//
//  SelectionHistoryLayerManager.h
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/10/28.
//  Copyright 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface SelectionHistoryLayer : CALayer
{
	NSRect _frameInLocal;
	BOOL _hoverd;
}
- (BOOL)isEqualToRect:(NSRect)rect;
- (void)setHovered:(BOOL)selected;
@end


@class SelectionHistoryLayerManager;
@protocol SelectionHistoryLayerManagerDelegate

- (void)animationDidStop:(SelectionHistoryLayerManager*)selectionHistoryLayer;

@end

@interface SelectionHistoryLayerManager : NSObject {

	CALayer* _baseLayer;
	
	SelectionHistoryLayer* _hoveredLayer;
	
	id <SelectionHistoryLayerManagerDelegate> _delegate;
	
	BOOL _endAfterAnimation;
	
	SelectionHistoryLayer* _dragedLayer;
	CGSize _draggedPointoffset;
}

@property (nonatomic, assign) id <SelectionHistoryLayerManagerDelegate> delegate;

- (void)addLayerToView:(NSView*)view currentRect:(NSRect)currentRect;

- (void)animateStart:(NSRect)rect;
- (void)animateSelect:(NSRect)rect;
- (void)animateCancel:(NSRect)rect;

- (void)mouseMoved:(NSEvent *)theEvent location:(NSPoint)cp currentRect:(NSRect)rect;
- (NSRect)rectAtPoint:(NSPoint)cp;


- (void)startDragAtPoint:(NSPoint)cp;
- (void)moveDragAtPoint:(NSPoint)cp;
- (void)endDrag;

@end
