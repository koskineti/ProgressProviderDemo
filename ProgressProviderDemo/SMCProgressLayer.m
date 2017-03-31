//
//  SMCProgressLayer.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 30/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCProgressLayer.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kProgressPropertyKeyPath = @"progress";

@interface SMCProgressLayer ()

@property (weak, nonatomic) UIProgressView *progressView;

@end

@implementation SMCProgressLayer

@dynamic progress;

#pragma mark - Properties

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    if (animated)
    {
        self.progress = progress;
    }
    else
    {
        [CATransaction begin];
        [CATransaction setValue:@(YES) forKey:kCATransactionDisableActions];

        self.progress = progress;

        [CATransaction commit];
    }
}

#pragma mark - Initialization

+ (instancetype)layerWithProgressView:(UIProgressView *)progressView
{
    return [[[self class] alloc] initWithProgressView:progressView];
}

- (instancetype)initWithProgressView:(UIProgressView *)progressView
{
    self = [super init];

    if (self != nil)
    {
        _progressView = progressView;
    }

    return self;
}

- (instancetype)initWithLayer:(id)layer
{
    self = [super initWithLayer:layer];

    if (self != nil)
    {
        if ([layer isKindOfClass:[SMCProgressLayer class]])
        {
            self.progress = ((SMCProgressLayer *)layer).progress;
        }
    }

    return self;
}

#pragma mark - Public

- (void)finishWithProgress:(float)progress
{
    [self setProgress:progress animated:NO];
    [self removeAnimationForKey:kProgressPropertyKeyPath];
    [self addAnimation:[self _linearProgressAnimation] forKey:kProgressPropertyKeyPath];

    //    self.timeOffset = [self convertTime:CACurrentMediaTime() fromLayer:nil];
    //    self.beginTime = CACurrentMediaTime();
    //    self.speed = 2.0f;
}

- (void)finish
{
    [self finishWithProgress:1.0f];
}

- (void)cancel
{
    [self removeAnimationForKey:kProgressPropertyKeyPath];

}

#pragma mark - CALayer

+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:kProgressPropertyKeyPath])
    {
        return YES;
    }
    else
    {
        return [super needsDisplayForKey:key];
    }
}

- (nullable id<CAAction>)actionForKey:(NSString *)key
{
    if ([key isEqualToString:kProgressPropertyKeyPath])
    {
        return [self _cubicBezierProgressAnimation];
    }
    else
    {
        return [super actionForKey:key];
    }
}

- (void)display
{
    self.progressView.progress = self.presentationLayer.progress;
}

#pragma mark - Private

- (CAAnimation *)_linearProgressAnimation
{
    NSTimeInterval duration = 0.3f;
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    return [self _progressAnimationWithDuration:duration timingFunction:timingFunction];
}

- (CAAnimation *)_cubicBezierProgressAnimation
{
    NSTimeInterval duration = 10.0f;
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.20f :0.33f :0.33f :1.0f];
//    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.0f :0.5f :0.2f :1.0f];

    return [self _progressAnimationWithDuration:duration timingFunction:timingFunction];
}

- (CAAnimation *)_progressAnimationWithDuration:(NSTimeInterval)duration timingFunction:(CAMediaTimingFunction *)timingFunction
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kProgressPropertyKeyPath];
    animation.fromValue = @(self.presentationLayer.progress);
    animation.timingFunction = timingFunction;
    animation.duration = duration;
    
    return animation;
}

@end

NS_ASSUME_NONNULL_END
