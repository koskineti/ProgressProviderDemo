//
//  SMCProgressLayer.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 30/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCProgressLayer.h"

#import "SMCProgressDisplay.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const kProgressPropertyKeyPath = @"progress";

@interface SMCProgressLayer ()

@property (weak, nonatomic) id<SMCProgressDisplay> progressDisplay;

@property (nonatomic) CFTimeInterval animationBeginTime;
@property (nonatomic) CFTimeInterval animationDuration;

@end

@implementation SMCProgressLayer

@dynamic progress;

#pragma mark - Properties

- (void)setProgress:(float)progress lastUpdateTime:(CFTimeInterval)lastUpdateTime
{
    float progressDelta = fabsf(progress - self.presentationLayer.progress);

    CFTimeInterval currentTime = [self convertTime:CACurrentMediaTime() toLayer:nil];
    CFTimeInterval timeSinceLastUpdate = currentTime - lastUpdateTime;
    CFTimeInterval duration = [self _animationDurationForProgressDelta:progressDelta];

    if (timeSinceLastUpdate < duration)
    {
        // Fewer than `duration` seconds have elapsed since `-setProgress:` was originally called,
        // meaning the previous progress animation did not complete. In this case, shift the
        // beginning time of the new animation to the past to make the animation appear to start
        // as if it had already been running for (duration - timeSinceLastUpdate) seconds.
        self.animationBeginTime = currentTime - timeSinceLastUpdate;
        self.animationDuration = duration;
        self.progress = progress;
    }
    else
    {
        [self setProgress:progress animated:NO];
    }
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    if (animated)
    {
        float progressDelta = fabsf(progress - self.presentationLayer.progress);

        self.animationBeginTime = 0.0;
        self.animationDuration = [self _animationDurationForProgressDelta:progressDelta];
        self.progress = progress;
    }
    else
    {
        [CATransaction begin];
        [CATransaction setValue:@(YES) forKey:kCATransactionDisableActions];

        self.progress = progress;

        [CATransaction commit];

        // Even though the model layer's progress property was updated within a
        // transaction, the presentation layer may not catch up until the runloop
        // cycle ends. This may cause subsequent animations to start from the
        // previous presentation layer property value if `-setProgress:animated:`
        // is called in quick succession with animation disabled and enabled.
        // To make absolutely sure the model and presentation layers are in sync,
        // flush all pending transactions here.
        [CATransaction flush];

        self.progressDisplay.progress = progress;
    }
}

#pragma mark - Initialization

+ (instancetype)layerWithProgressDisplay:(id<SMCProgressDisplay>)progressDisplay
{
    return [[[self class] alloc] initWithProgressDisplay:progressDisplay];
}

- (instancetype)initWithProgressDisplay:(id<SMCProgressDisplay>)progressDisplay
{
    self = [super init];

    if (self != nil)
    {
        _progressDisplay = progressDisplay;
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
    [self removeAnimationForKey:kProgressPropertyKeyPath];
    [self addAnimation:[self _linearProgressAnimation] forKey:kProgressPropertyKeyPath];
    [self setProgress:progress animated:NO];
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
    self.progressDisplay.progress = self.presentationLayer.progress;
}

#pragma mark - Private

- (CFTimeInterval)_animationDurationForProgressDelta:(float)progressDelta
{
    if (progressDelta < 0.5f)
    {
        return 20.0;
    }
    else
    {
        return 35.0;
    }
}

- (CAAnimation *)_cubicBezierProgressAnimation
{
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.20f :0.33f :0.33f :1.0f];
    CAAnimation *animation = [self _progressAnimationWithDuration:self.animationDuration timingFunction:timingFunction];

    if (self.animationBeginTime > 0)
    {
        animation.beginTime = self.animationBeginTime;
    }

    return animation;
}

- (CAAnimation *)_linearProgressAnimation
{
    CFTimeInterval duration = 0.3f;
    CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    return [self _progressAnimationWithDuration:duration timingFunction:timingFunction];
}

- (CAAnimation *)_progressAnimationWithDuration:(CFTimeInterval)duration timingFunction:(CAMediaTimingFunction *)timingFunction
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:kProgressPropertyKeyPath];
    animation.fromValue = @(self.presentationLayer.progress);
    animation.timingFunction = timingFunction;
    animation.duration = duration;
    
    return animation;
}

@end

NS_ASSUME_NONNULL_END
