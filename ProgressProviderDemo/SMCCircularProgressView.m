//
//  SMCCircularProgressView.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 19/04/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCCircularProgressView.h"

#import "MKCUIColorAdditions.h"

NS_ASSUME_NONNULL_BEGIN

static const CGFloat kTrackLineWidth = 3.0f;
static const CGFloat kProgressLineWidth = 3.0f;
static const CGFloat kProgressAngleOffset = 0.0f;

static const NSUInteger kTrackStrokeColor = 0x474747;
static const NSUInteger kProgressStrokeColor = 0x1da9ea;

@interface SMCCircularProgressView ()

@property (nonatomic) CAShapeLayer *trackShapeLayer;
@property (nonatomic) CAShapeLayer *progressShapeLayer;

@property (nonatomic) CGFloat progressLayerStrokeEnd;

@end

@implementation SMCCircularProgressView

#pragma mark - Properties

- (float)progress
{
    return self.progressLayerStrokeEnd;
}

- (void)setProgress:(float)progress
{
    self.progressLayerStrokeEnd = fmaxf(0.0f, fminf(progress, 1.0f));

    if (self.progressShapeLayer != nil)
    {
        // Always disable implicit layer animations before setting the stroke
        // start and end values. The progress animation is driven by the class
        // `SMCProgressLayer` that forwards its property value changes to this
        // view using a custom timing curve.
        [CATransaction begin];
        [CATransaction setValue:@(YES) forKey:kCATransactionDisableActions];

        self.trackShapeLayer.strokeStart = self.progressLayerStrokeEnd;
        self.progressShapeLayer.strokeEnd = self.progressLayerStrokeEnd;

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

    [self _setTrackShapeLayerFrame:layerFrame];
    [self _setProgressShapeLayerFrame:layerFrame];
}

#pragma mark - Private

- (void)_init
{
//    self.backgroundColor = UIColor.blueColor;
}

- (void)_setTrackShapeLayerFrame:(CGRect)layerFrame
{
    if (self.trackShapeLayer == nil)
    {
        CAShapeLayer *trackShapeLayer = [CAShapeLayer new];
        trackShapeLayer.lineWidth = kTrackLineWidth;
        trackShapeLayer.lineCap = kCALineCapRound;
        trackShapeLayer.fillColor = UIColor.clearColor.CGColor;
        trackShapeLayer.strokeColor = [UIColor richie_colorWithRGB:kTrackStrokeColor].CGColor;
        trackShapeLayer.strokeStart = self.progressLayerStrokeEnd;

        [self.layer addSublayer:trackShapeLayer];

        self.trackShapeLayer = trackShapeLayer;
    }

    self.trackShapeLayer.frame = layerFrame;
    self.trackShapeLayer.path = [self _circularPathWithLayerFrame:layerFrame lineWidth:kTrackLineWidth angleOffset:0.0f];
}

- (void)_setProgressShapeLayerFrame:(CGRect)layerFrame
{
    if (self.progressShapeLayer == nil)
    {
        CAShapeLayer *progressShapeLayer = [CAShapeLayer new];
        progressShapeLayer.lineWidth = kTrackLineWidth;
        progressShapeLayer.lineCap = kCALineCapRound;
        progressShapeLayer.fillColor = UIColor.clearColor.CGColor;
        progressShapeLayer.strokeColor = [UIColor richie_colorWithRGB:kProgressStrokeColor].CGColor;
        progressShapeLayer.strokeEnd = self.progressLayerStrokeEnd;

        [self.layer addSublayer:progressShapeLayer];

        self.progressShapeLayer = progressShapeLayer;
    }

    self.progressShapeLayer.frame = layerFrame;
    self.progressShapeLayer.path = [self _circularPathWithLayerFrame:layerFrame lineWidth:kProgressLineWidth angleOffset:kProgressAngleOffset];
//    self.progressShapeLayer.strokeEnd = 1.0f;
}

- (CGRect)_layerFrame
{
    CGFloat side = MIN(self.bounds.size.width, self.bounds.size.height);
    CGFloat x = (CGRectGetWidth(self.bounds) - side) / 2.0f;
    CGFloat y = (CGRectGetHeight(self.bounds) - side) / 2.0f;

    return CGRectIntegral(CGRectMake(x, y, side, side));
}

- (CGPathRef)_circularPathWithLayerFrame:(CGRect)frame lineWidth:(CGFloat)lineWidth angleOffset:(CGFloat)angleOffset
{
    CGFloat diameter = MIN(CGRectGetWidth(frame), CGRectGetHeight(frame));
    CGFloat centerXY = diameter / 2.0f;
    CGPoint center = CGPointMake(centerXY, centerXY);
    CGFloat radius = (diameter - lineWidth) / 2.0f;

    CGFloat startAngle = (-M_PI / 2.0f) + angleOffset;
    CGFloat endAngle = (1.5f * M_PI) - angleOffset;

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                         radius:radius
                                                     startAngle:startAngle
                                                       endAngle:endAngle
                                                      clockwise:YES];

    return path.CGPath;
}

@end

NS_ASSUME_NONNULL_END
