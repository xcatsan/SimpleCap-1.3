//
//  SelectionHistoryLayerManager.m
//  SimpleCap
//
//  Created by Hiroshi Hashiguchi on 10/10/28.
//  Copyright 2010 . All rights reserved.
//
#import <QuartzCore/CATransform3D.h>

#import "SelectionHistoryLayerManager.h"
#import "CoordinateConverter.h"

#import "SelectionHistory.h"
#import <math.h>

#pragma mark -
#pragma mark a selection history layer

@implementation SelectionHistoryLayer

#pragma mark -
#pragma mark Initialization and deallocation

- (void)setNormalAppearance
{
	CGColorRef colorRef;

	colorRef= CGColorCreateGenericGray(0.5f, 0.25f);
	self.backgroundColor = colorRef;
	CGColorRelease(colorRef);

	colorRef= CGColorCreateGenericGray(0.5f, 1.0f);
	self.borderColor = colorRef;
	self.borderWidth = 1.0f;
	CGColorRelease(colorRef);
	
	[self setFilters:nil];
}

- (void)setHoveredAppearance
{
	CGColorRef colorRef;

	colorRef = CGColorCreateGenericRGB(43.0/255, 74.0/255, 255.0/255, 0.25f);
	self.backgroundColor = colorRef;
	CGColorRelease(colorRef);
	
	colorRef= CGColorCreateGenericGray(0.5f, 1.0f);
	self.borderColor = colorRef;
	self.borderWidth = 1.0f;
	CGColorRelease(colorRef);

}

- (id)initWithFrame:(NSRect)frame
{
	if (self = [super init]) {
		_frameInLocal = frame;
		self.frame = NSRectToCGRect(
									[CoordinateConverter convertFromLocalToNSScreenRect:frame]);
				
		[self setNormalAppearance];
		
		self.layoutManager = [CAConstraintLayoutManager layoutManager];
		
		// text layer
		CATextLayer* textLayer = [CATextLayer layer];
		textLayer.string = [NSString stringWithFormat:@"%d x %d",
							(int)frame.size.width, (int)frame.size.height];
		textLayer.font = @"Lucida-Grande";
		textLayer.fontSize = 13.5;
		textLayer.alignmentMode = kCAAlignmentCenter;
		
		CGColorRef colorRef;
		
		colorRef= CGColorCreateGenericGray(1.0f, 1.0f);
		textLayer.foregroundColor = colorRef;
		CGColorRelease(colorRef);
		
		colorRef= CGColorCreateGenericGray(0.0f, 1.0f);
		textLayer.shadowColor = colorRef;
		textLayer.shadowOffset = CGSizeMake(1.0, -1.0);
		textLayer.shadowOpacity = 0.5;
		CGColorRelease(colorRef);
		
		[textLayer addConstraint:[CAConstraint
								  constraintWithAttribute:kCAConstraintMidX
								  relativeTo:@"superlayer"
								  attribute:kCAConstraintMidX]];
        [textLayer addConstraint:[CAConstraint
								  constraintWithAttribute:kCAConstraintMidY
								  relativeTo:@"superlayer"
								  attribute:kCAConstraintMidY]];
		[self addSublayer:textLayer];
		
		CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
		[filter setDefaults];
		[filter setValue:[NSNumber numberWithFloat:5.0] forKey:@"inputRadius"];
		[filter setName:@"pulseFilter"];
		[textLayer setFilters:[NSArray arrayWithObject:filter]];
		
		CABasicAnimation* pulseAnimation = [CABasicAnimation animation];
		pulseAnimation.keyPath = @"filters.pulseFilter.inputIntensity";
		pulseAnimation.fromValue = [NSNumber numberWithFloat: 0.0];
		pulseAnimation.toValue = [NSNumber numberWithFloat: 2.0];
		pulseAnimation.duration = 1.5;
		pulseAnimation.repeatCount = 1e100f;
		pulseAnimation.autoreverses = YES;
		pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		[textLayer addAnimation:pulseAnimation forKey:@"pulseAnimation"];
		
		self.delegate = self;
	}
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

- (BOOL)isEqualToRect:(NSRect)rect
{
	return NSEqualRects(rect, _frameInLocal);
}

- (void)setHovered:(BOOL)hovered
{
	if (hovered) {
		[self setHoveredAppearance];
	} else {
		[self setNormalAppearance];
	}
	_hoverd = hovered;
}

#define CORNER_RADIUS	10
#define BADGE_WIDTH		10
#define BADGE_HEIGHT	10
#define BADGE_OFFSET_Y  20
- (void)addRoundRectPath:(CGContextRef)context rect:(CGRect)rect
{
	// Top Left
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + CORNER_RADIUS);
	CGContextAddArcToPoint(context,
						   rect.origin.x,
						   rect.origin.y,
						   rect.origin.x + CORNER_RADIUS,
						   rect.origin.y,
						   CORNER_RADIUS);
	// Top right
	CGContextAddArcToPoint(context,
						   rect.origin.x + rect.size.width,
						   rect.origin.y,
						   rect.origin.x + rect.size.width,
						   rect.origin.y + CORNER_RADIUS,
						   CORNER_RADIUS);
	// Bottom right
	CGContextAddArcToPoint(context,
						   rect.origin.x + rect.size.width,
						   rect.origin.y + rect.size.height,
						   rect.origin.x + rect.size.width - CORNER_RADIUS,
						   rect.origin.y + rect.size.height,
						   CORNER_RADIUS);
	// Bottom left
	CGContextAddArcToPoint(context,
						   rect.origin.x,
						   rect.origin.y + rect.size.height,
						   rect.origin.x,
						   rect.origin.y,
						   CORNER_RADIUS);
	
	CGContextClosePath(context);
} 

- (void)drawInContext:(CGContextRef)context
{
	return;
	CGPoint center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);

	CGRect rect = CGRectMake(center.x - CORNER_RADIUS - BADGE_WIDTH/2.0,
							 center.y - CORNER_RADIUS - BADGE_HEIGHT/2.0 - BADGE_OFFSET_Y,
							 CORNER_RADIUS*2+BADGE_WIDTH, CORNER_RADIUS*2);
	CGContextSetRGBFillColor(context, 0.75, 0.75, 0.75, 0.75);
	[self addRoundRectPath:context rect:rect];
    CGContextFillPath(context);

	
	CGFontRef font = CGFontCreateWithFontName((CFStringRef)@"Lucida-Grande");
	CGContextSetFont(context, font);
	CGContextSetFontSize(context, 12);
	CGContextSetTextDrawingMode(context, kCGTextFill);
	CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	CGContextSetTextMatrix(context, CGAffineTransformMakeScale(1, -1));
	CGContextShowTextAtPoint(context, center.x-10, center.y-10, "100", 3);
								
}

@end


////////////////////////////////////////////////
#pragma mark -

@implementation SelectionHistoryLayerManager
@synthesize delegate = _delegate;

#define ANIMATION_DURATION 0.25

#pragma mark -
#pragma mark animation

- (void)setTextHidden:(BOOL)hidden
{
	for (CALayer* layer in _baseLayer.sublayers) {
		CATextLayer* textLayer = (CATextLayer*)[layer.sublayers objectAtIndex:0];
		textLayer.hidden = hidden;
	}	
}

- (void)animateFadeInOut:(BOOL)flag
{
	CGFloat zPositionFrom;
	CGFloat zPositionTo;
	CGFloat opacityFrom;
	CGFloat opacityTo;
	
	if (flag) {
		// fade-in
		zPositionFrom = -500;
		zPositionTo   = 0;
		opacityFrom   = 0.0;
		opacityTo     = 1.0;
	} else {
		// fade-out
		zPositionFrom = 0;
		zPositionTo   = -500;
		opacityFrom   = 1.0;
		opacityTo     = 0.25;
	}
	
	BOOL first = YES;
	for (CALayer* layer in _baseLayer.sublayers) {
		CABasicAnimation *animation;
		animation=[CABasicAnimation animationWithKeyPath:@"zPosition"];
		animation.fromValue=[NSNumber numberWithFloat:zPositionFrom];
		animation.toValue=[NSNumber numberWithFloat:zPositionTo];
		animation.duration=ANIMATION_DURATION;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		animation.repeatCount = 1;
		if (first) {
			animation.delegate = self;
			first = NO;
		}
		[layer addAnimation:animation forKey:@"zPosition"];
		
		animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
		animation.fromValue=[NSNumber numberWithFloat:opacityFrom];
		animation.toValue=[NSNumber numberWithFloat:opacityTo];
		animation.duration=ANIMATION_DURATION;
		animation.repeatCount = 1;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		[layer addAnimation:animation forKey:@"opacity"];
	}
}

- (void)moveRect:(NSRect)rect kind:(BOOL)flag
{
	rect = [CoordinateConverter convertFromLocalToNSScreenRect:rect];
	
	NSPoint position = NSMakePoint(NSMidX(rect),NSMidY(rect));
	NSRect bounds = rect;
	bounds.origin = NSZeroPoint;
	
	NSPoint positionFrom, positionTo;
	NSRect  boundsFrom  , boundsTo;
	CGFloat opacityFrom , opacityTo;

	BOOL first = YES;
	for (CALayer* layer in _baseLayer.sublayers) {
		
		if (flag) {
			// gather
			positionFrom = NSPointFromCGPoint(layer.position);
			positionTo   = position;
			boundsFrom   = NSRectFromCGRect(layer.bounds);
			boundsTo     = rect;
			opacityFrom  = 0.25;
			opacityTo    = 0.0;
		} else {
			// break
			positionFrom = position;
			positionTo   = NSPointFromCGPoint(layer.position);
			boundsFrom   = rect;
			boundsTo     = NSRectFromCGRect(layer.bounds);
			opacityFrom  = 0.1;
			opacityTo    = 1.0;
		}
		
		CABasicAnimation *animation;
		animation=[CABasicAnimation animationWithKeyPath:@"position"];
		animation.fromValue = [NSValue valueWithPoint:positionFrom];
		animation.toValue   = [NSValue valueWithPoint:positionTo];
		animation.duration  = ANIMATION_DURATION;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
		animation.repeatCount = 1;
		if (first) {
			animation.delegate = self;
			first = NO;
		}
		animation.removedOnCompletion = NO;
		[layer addAnimation:animation forKey:@"position"];
		
		animation=[CABasicAnimation animationWithKeyPath:@"bounds"];
		animation.fromValue = [NSValue valueWithRect:boundsFrom];
		animation.toValue   = [NSValue valueWithRect:boundsTo];
		animation.duration  = ANIMATION_DURATION;
		animation.repeatCount = 1;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		animation.removedOnCompletion = NO;
		[layer addAnimation:animation forKey:@"bounds"];
		
		animation=[CABasicAnimation animationWithKeyPath:@"opacity"];
		animation.fromValue = [NSNumber numberWithFloat:opacityFrom];
		animation.toValue   = [NSNumber numberWithFloat:opacityTo];
		animation.duration  = ANIMATION_DURATION;
		animation.repeatCount = 1;
		animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
		animation.removedOnCompletion = NO;
		[layer addAnimation:animation forKey:@"opacity"];
		
	}
}


- (void)animateStart:(NSRect)rect
{
	_endAfterAnimation = NO;
	[self setTextHidden:YES];
	[self animateFadeInOut:YES];
}

- (void)animateSelect:(NSRect)rect
{
	_endAfterAnimation = YES;
	[self setTextHidden:YES];
	[self moveRect:rect kind:YES];
}

- (void)animateCancel:(NSRect)rect
{
	_endAfterAnimation = YES;
	[self setTextHidden:YES];
	[self animateFadeInOut:NO];
}


-(id)init
{
	if (self = [super init]) {
		_hoveredLayer = nil;
		_delegate = nil;
		_endAfterAnimation = NO;
	}
	return self;
}	


- (void)setHoveredLayer:(SelectionHistoryLayer*)layer
{
	if (_hoveredLayer == layer) {
		return;
	}
	
	[_hoveredLayer setHovered:NO];
	if (layer) {
		_hoveredLayer = layer;
		[_hoveredLayer setHovered:YES];
	}
}


#pragma mark -
#pragma mark Initialization and deallocation
- (void)addLayerToView:(NSView*)view currentRect:(NSRect)currentRect
{
	// [1] recreate base layer and set to hosting view
	if (_baseLayer) {
		[_baseLayer removeFromSuperlayer];
		[_baseLayer release];
		_hoveredLayer = nil;
	}
	_baseLayer = [[CALayer alloc] init];
	view.layer = _baseLayer;
	
	_baseLayer.frame = NSRectToCGRect(view.frame);

	CATransform3D transform = CATransform3DMakeRotation(0, 0, 0, 0); 
	transform.m34 = 1.0 / 1000;
	_baseLayer.sublayerTransform = transform;


	// [2] history selection layers
	NSMutableDictionary *noAnimationActions = [[[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"frame",
									   [NSNull null], @"onOrderOut",
									   [NSNull null], @"sublayers",
									   [NSNull null], @"contents",
												[NSNull null], @"bounds",
												[NSNull null], @"frame",
									   nil] autorelease];

	BOOL hasExisted = NO;
	for (SelectionHistoryEntry* entry in
		 [[SelectionHistory sharedSelectionHistory] arrayOrderBySizeDesc]) {
		
		if (NSEqualRects(currentRect, entry.rect)) {
			hasExisted = YES;
		}
		SelectionHistoryLayer* layer =
			[[[SelectionHistoryLayer alloc]  initWithFrame:entry.rect] autorelease];
		[_baseLayer addSublayer:layer];
		layer.actions = noAnimationActions;
	}
	
	// [3] current selection
	/*
	if (!hasExisted) {
		SelectionHistoryLayer* layer =
			[[[SelectionHistoryLayer alloc]  initWithFrame:currentRect] autorelease];		
		[_baseLayer addSublayer:layer];
		[self setHoveredLayer:layer];
	}
	 */
}

- (void) dealloc
{
	[_baseLayer release];
	[super dealloc];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
//	NSLog(@"%s", __PRETTY_FUNCTION__);
	if (_endAfterAnimation) {
		[_delegate animationDidStop:self];
	} else {
		[self setTextHidden:NO];
	}
	// call drawInContext;
	for (SelectionHistoryLayer* layer in _baseLayer.sublayers) {
		[layer setNeedsDisplay];
	}
}

- (SelectionHistoryLayer*)layerForRect:(NSRect)rect
{
	for (SelectionHistoryLayer* layer in _baseLayer.sublayers) {
		if ([layer isEqualToRect:rect]) {
			return layer;
		}
	}
	return nil;
}

- (NSRect)rectAtPoint:(NSPoint)cp
{
	NSRect rect = NSZeroRect;
	for (SelectionHistoryEntry* entry in
		 [[SelectionHistory sharedSelectionHistory] arrayOrderBySize]) {
		if (NSPointInRect(cp, entry.rect)) {
			rect = entry.rect;
			break;
		}
	}
	
	return rect;
}



#pragma mark -
#pragma mark Event
- (void)mouseMoved:(NSEvent *)theEvent location:(NSPoint)cp currentRect:(NSRect)rect
{
	BOOL hit = NO;
	SelectionHistory* selectionHistory = [SelectionHistory sharedSelectionHistory];
	for (SelectionHistoryEntry* entry in [selectionHistory arrayOrderBySize]) {
		if (NSPointInRect(cp, entry.rect)) {
			[self setHoveredLayer:[self layerForRect:entry.rect]];
			hit = YES;
			break;
		}
	}
	if (!hit && NSPointInRect(cp, rect)) {
		[self setHoveredLayer:[self layerForRect:rect]];
	}
	
}

#pragma mark -
#pragma mark Handling drag event
- (void)startDragAtPoint:(NSPoint)cp
{
	NSRect rect = [self rectAtPoint:cp];
	_dragedLayer = [self layerForRect:rect];
	CGRect layerFrame = _dragedLayer.frame;

	CGPoint cp2 = NSPointToCGPoint([CoordinateConverter convertFromLocalToNSScreenPoint:cp]);

	_draggedPointoffset.width = layerFrame.origin.x - cp2.x;
	_draggedPointoffset.height = layerFrame.origin.y - cp2.y;

}
- (void)moveDragAtPoint:(NSPoint)cp
{
	CGPoint cp2 = NSPointToCGPoint([CoordinateConverter convertFromLocalToNSScreenPoint:cp]);
	CGRect frame = _dragedLayer.frame;
	frame.origin.x = cp2.x + _draggedPointoffset.width;
	frame.origin.y = cp2.y + _draggedPointoffset.height;
	_dragedLayer.frame = frame;
}

- (void)endDrag
{
	_dragedLayer = nil;
	_draggedPointoffset = CGSizeZero;
}

@end
