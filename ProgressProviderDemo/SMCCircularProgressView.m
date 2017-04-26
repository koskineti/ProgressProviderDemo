//
//  SMCCircularProgressView.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 19/04/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCCircularProgressView.h"

NS_ASSUME_NONNULL_BEGIN

// `CGFloat` is defined as `float` on 32-bit systems and as `double` on 64-bit systems.
// For this reason, when comparing `CGFloat` values we have to use the `MIN`, `MAX`, and `ABS`
// macros instead of choosing one of the C standard library functions, e.g. `fminf` for
// floats or `fmin` for doubles. For the same reason, we define a `CGFloat` specific
// epsilon value here to determine if a CoreGraphics floating point value has changed
// with the expression `(ABS(cgFloat1 - cgFloat2) > CGFLOAT_EPSILON)`.
#ifdef CGFLOAT_IS_DOUBLE
static const CGFloat CGFLOAT_EPSILON = DBL_EPSILON;
#else
static const CGFloat CGFLOAT_EPSILON = FLT_EPSILON;
#endif

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
    if (ABS(_lineWidth - lineWidth) > CGFLOAT_EPSILON)
    {
        _lineWidth = lineWidth;

        self.trackShapeLayer.lineWidth = lineWidth;
        self.progressShapeLayer.lineWidth = lineWidth;

        [self setNeedsLayout];
    }
}

- (void)setAngleOffset:(CGFloat)angleOffset
{
    // Clamp the incoming angle offset to the range [0..2pi] radians, i.e., to a full circle.
    angleOffset = (CGFloat)MAX(0.0, MIN(angleOffset, (2 * M_PI)));

    if (ABS(_angleOffset - angleOffset) > CGFLOAT_EPSILON)
    {
        _angleOffset = angleOffset;

        [self setNeedsLayout];
    }
}

- (void)setProgress:(float)progress
{
    // Clamp the incoming progress value to the range [0..1].
    progress = fmaxf(0.0f, fminf(progress, 1.0f));

    if ((fabsf(_progress - progress) > FLT_EPSILON))
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

    [self.layer addSublayer:trackShapeLayer];
    [self.layer addSublayer:progressShapeLayer];

    _trackColor = UIColor.clearColor;
    _lineWidth = 3.0;
    _angleOffset = 0.0;

    _progressShapeLayer = progressShapeLayer;
    _trackShapeLayer = trackShapeLayer;
}

- (void)_layoutTrackShapeWithLayerFrame:(CGRect)layerFrame
{
    self.trackShapeLayer.frame = layerFrame;
    self.trackShapeLayer.lineWidth = self.lineWidth;
    self.trackShapeLayer.strokeColor = self.trackColor.CGColor;
    self.trackShapeLayer.strokeStart = self.progress;
    self.trackShapeLayer.path = [self _circularPathWithLayerFrame:layerFrame];
}

- (void)_layoutProgressShapeWithLayerFrame:(CGRect)layerFrame
{
    self.progressShapeLayer.frame = layerFrame;
    self.progressShapeLayer.lineWidth = self.lineWidth;
    self.progressShapeLayer.strokeColor = self.tintColor.CGColor;
    self.progressShapeLayer.strokeEnd = self.progress;
    self.progressShapeLayer.path = [self _circularPathWithLayerFrame:layerFrame];
}

- (CGRect)_layerFrame
{
    CGFloat side = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat x = (CGRectGetWidth(self.bounds) - side) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - side) / 2;

    return CGRectIntegral(CGRectMake(x, y, side, side));
}

- (CGPathRef)_circularPathWithLayerFrame:(CGRect)frame
{
    CGFloat diameter = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame));
    CGFloat centerXY = diameter / 2;
    CGPoint center = CGPointMake(centerXY, centerXY);
    CGFloat radius = (diameter - self.lineWidth) / 2;

    CGFloat startAngle = -(CGFloat)M_PI_2 + self.angleOffset;
    CGFloat endAngle = (2 * ((CGFloat)M_PI - self.angleOffset)) + startAngle;

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                         radius:radius
                                                     startAngle:startAngle
                                                       endAngle:endAngle
                                                      clockwise:YES];

    return path.CGPath;
}

@end

NS_ASSUME_NONNULL_END
