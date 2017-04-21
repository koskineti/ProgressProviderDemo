//
//  SMCCircularProgressView.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 19/04/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCCircularProgressView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCCircularProgressView ()

@property (nonatomic) CAShapeLayer *trackShapeLayer;
@property (nonatomic) CAShapeLayer *progressShapeLayer;

@end

@implementation SMCCircularProgressView

// Automatic property synthesis does not synthesize properties declared in protocols.
// We need to manually synthesize the `SMCProgressDisplay` protocol's `progress` property.
@synthesize progress = _progress;

#pragma mark - Properties

- (void)setTrackColor:(UIColor *)trackColor
{
    if (![_trackColor isEqual:trackColor])
    {
        _trackColor = trackColor;

        self.trackShapeLayer.strokeColor = trackColor.CGColor;

        [self setNeedsDisplay];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    if (![self _isCGFloatValue:_lineWidth equalTo:lineWidth])
    {
        _lineWidth = lineWidth;

        self.trackShapeLayer.lineWidth = lineWidth;
        self.progressShapeLayer.lineWidth = lineWidth;

        [self setNeedsLayout];
    }
}

- (void)setAngleOffset:(CGFloat)angleOffset
{
    angleOffset = [self _clampCGFloatValue:angleOffset minimum:0.0 maximum:(2 * M_PI)];

    if (![self _isCGFloatValue:_angleOffset equalTo:angleOffset])
    {
        _angleOffset = angleOffset;

        [self setNeedsLayout];
    }
}

- (void)setProgress:(float)progress
{
    progress = [self _clampFloatValue:progress minimum:0.0f maximum:1.0f];

    if (![self _isFloatValue:_progress equalTo:progress])
    {
        _progress = progress;

        // Always disable implicit layer animations before setting the stroke
        // start and end values. The progress animation is driven by the class
        // `SMCProgressLayer` that forwards its property value changes to this
        // view using a custom timing curve.
        [CATransaction begin];
        [CATransaction setValue:@(YES) forKey:kCATransactionDisableActions];

        self.trackShapeLayer.strokeStart = (CGFloat)progress;
        self.progressShapeLayer.strokeEnd = (CGFloat)progress;

        [CATransaction commit];
        [CATransaction flush];
    }
}

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self != nil)
    {
        [self _init];
    }

    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];

    if (self != nil)
    {
        [self _init];
    }

    return self;
}

#pragma mark - UIView

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect layerFrame = [self _layerFrame];

    [self _layoutTrackShapeWithLayerFrame:layerFrame];
    [self _layoutProgressShapeWithLayerFrame:layerFrame];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];

    self.progressShapeLayer.strokeColor = self.tintColor.CGColor;

    [self setNeedsDisplay];

}

#pragma mark - NSObject(UINibLoadingAdditions)

- (void)prepareForInterfaceBuilder
{
    [self _init];
    [super prepareForInterfaceBuilder];
}

#pragma mark - Private

- (void)_init
{
    CAShapeLayer *trackShapeLayer = [CAShapeLayer new];
    trackShapeLayer.lineCap = kCALineCapRound;
    trackShapeLayer.fillColor = UIColor.clearColor.CGColor;

    CAShapeLayer *progressShapeLayer = [CAShapeLayer new];
    progressShapeLayer.lineCap = kCALineCapRound;
    progressShapeLayer.fillColor = UIColor.clearColor.CGColor;
    progressShapeLayer.strokeEnd = 0.0f;

    [self.layer addSublayer:trackShapeLayer];
    [self.layer addSublayer:progressShapeLayer];

    _trackColor = UIColor.clearColor;
    _lineWidth = 3.0f;
    _angleOffset = 0.0f;

    _progressShapeLayer = progressShapeLayer;
    _trackShapeLayer = trackShapeLayer;
}

- (void)_layoutTrackShapeWithLayerFrame:(CGRect)layerFrame
{
    self.trackShapeLayer.frame = layerFrame;
    self.trackShapeLayer.lineWidth = self.lineWidth;
    self.trackShapeLayer.strokeColor = self.trackColor.CGColor;
    self.trackShapeLayer.path = [self _circularPathWithLayerFrame:layerFrame];
}

- (void)_layoutProgressShapeWithLayerFrame:(CGRect)layerFrame
{
    self.progressShapeLayer.frame = layerFrame;
    self.progressShapeLayer.lineWidth = self.lineWidth;
    self.progressShapeLayer.strokeColor = self.tintColor.CGColor;
    self.progressShapeLayer.path = [self _circularPathWithLayerFrame:layerFrame];
}

- (CGRect)_layerFrame
{
    CGFloat side = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat x = (CGRectGetWidth(self.bounds) - side) / 2.0f;
    CGFloat y = (CGRectGetHeight(self.bounds) - side) / 2.0f;

    return CGRectIntegral(CGRectMake(x, y, side, side));
}

- (CGPathRef)_circularPathWithLayerFrame:(CGRect)frame
{
    CGFloat diameter = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame));
    CGFloat centerXY = diameter / 2.0f;
    CGPoint center = CGPointMake(centerXY, centerXY);
    CGFloat radius = (diameter - self.lineWidth) / 2.0f;

    CGFloat startAngle = -M_PI_2 + self.angleOffset;
    CGFloat endAngle = (2.0f * (M_PI - self.angleOffset)) + startAngle;

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                         radius:radius
                                                     startAngle:startAngle
                                                       endAngle:endAngle
                                                      clockwise:YES];

    return path.CGPath;
}

- (CGFloat)_clampCGFloatValue:(CGFloat)value minimum:(CGFloat)minimum maximum:(CGFloat)maximum
{
    // `CGFloat` is defined as `float` on 32-bit systems and as `double` on 64-bit systems.
    // For this reason, when comparing CGFloats we have to choose the correct C standard library
    // functions and constants depending on which type we're dealing with. E.g. `fminf` and
    // `FLT_EPSILON` for floats or `fmin` and `DBL_EPSILON` for doubles.
#ifdef CGFLOAT_IS_DOUBLE
    return [self _clampDoubleValue:value minimum:minimum maximum:maximum];
#else
    return [self _clampFloatValue:value minimum:minimum maximum:maximum];
#endif
}

- (float)_clampFloatValue:(float)value minimum:(float)minimum maximum:(float)maximum
{
    return fmaxf(minimum, fminf(value, maximum));
}

- (double)_clampDoubleValue:(double)value minimum:(double)minimum maximum:(double)maximum
{
    return fmax(minimum, fmin(value, maximum));
}

- (BOOL)_isCGFloatValue:(CGFloat)value equalTo:(CGFloat)other
{
#ifdef CGFLOAT_IS_DOUBLE
    return [self _isDoubleValue:value equalTo:other];
#else
    return [self _isFloatValue:value equalTo:other];
#endif
}

- (BOOL)_isFloatValue:(float)value equalTo:(float)other
{
    return (fabsf(value - other) <= FLT_EPSILON);
}

- (BOOL)_isDoubleValue:(double)value equalTo:(double)other
{
    return (fabs(value - other) <= DBL_EPSILON);
}

@end

NS_ASSUME_NONNULL_END
