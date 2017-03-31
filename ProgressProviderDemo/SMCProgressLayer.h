//
//  SMCProgressLayer.h
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 30/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class UIProgressView;

NS_ASSUME_NONNULL_BEGIN

@interface SMCProgressLayer : CALayer

@property (nonatomic) float progress;

+ (instancetype)layerWithProgressView:(UIProgressView *)progressView;

- (instancetype)initWithProgressView:(UIProgressView *)progressView;

- (void)setProgress:(float)progress animated:(BOOL)animated;
- (void)finishWithProgress:(float)progress;
- (void)finish;
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
