//
//  SMCDeviceSyncProgressViewController.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 23/03/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCProgressViewController.h"

#import "SMCProgressLayer.h"
#import "SMCProgressProvider.h"
#import "UIProgressView+SMCAdditions.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCProgressViewController ()

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, nullable) SMCProgressLayer *progressLayer;
@property (nonatomic, nullable) NSLayoutConstraint *heightLayoutConstaint;

@end

@implementation SMCProgressViewController

#pragma mark - Properties

- (float)progress
{
    return self.progressLayer.progress;
}

- (void)setProgress:(float)progress
{
    self.progressLayer.progress = progress;
}

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    [self.progressLayer setProgress:progress animated:animated];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.progressLayer = [SMCProgressLayer layerWithProgressDisplay:self.progressView];

    [self.view.layer addSublayer:self.progressLayer];
}

- (void)viewDidLayoutSubviews
{
    if ((self.parentViewController != nil) && (self.heightLayoutConstaint == nil))
    {
        CGFloat statusBarHeight = self.parentViewController.topLayoutGuide.length;

        // Status bar height may still be reported as zero if the status bar is already
        // hidden for our parent view controller. We still have to give a sensible height
        // for our own view here, so use a hardcoded height of 20 points which matches
        // the actual status bar height as of iOS 10. Note that even if the status bar
        // height were to change in the future, this would cause no greater harm than
        // the progress bar to not be vertically centered in the status bar area.
        if (fabs(statusBarHeight) < FLT_EPSILON)
        {
            statusBarHeight = 20.0f;
        }

        self.heightLayoutConstaint = [self.view.heightAnchor constraintEqualToConstant:statusBarHeight];
        self.heightLayoutConstaint.active = YES;
    }
}

#pragma mark - SMCProgressObserver

- (void)progressProvider:(SMCProgressProvider *)provider didUpdateProgress:(float)progress
{
    [self.progressLayer setProgress:progress animated:YES];
}

- (void)progressProviderDidBecomeActive:(SMCProgressProvider *)provider
{
    [self.progressLayer setProgress:0.0f animated:NO];
    [self.progressLayer setProgress:provider.progress animated:YES];
}

- (void)progressProviderDidFinish:(SMCProgressProvider *)provider
{
    [self.progressLayer finish];
}

- (void)progressProviderDidCancel:(SMCProgressProvider *)provider
{
    [self.progressLayer cancel];
}

@end

NS_ASSUME_NONNULL_END
