//
//  SMCProgressLayer.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 30/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@protocol SMCProgressDisplay;

NS_ASSUME_NONNULL_BEGIN

@interface SMCProgressLayer : CALayer

@property (nonatomic) float progress;

+ (instancetype)layerWithProgressDisplay:(id<SMCProgressDisplay>)progressDisplay;

- (instancetype)initWithProgressDisplay:(id<SMCProgressDisplay>)progressDisplay;

- (void)setProgress:(float)progress lastUpdateTime:(CFTimeInterval)lastUpdateTime;
- (void)setProgress:(float)progress animated:(BOOL)animated;
- (void)finishWithProgress:(float)progress;
- (void)finish;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
