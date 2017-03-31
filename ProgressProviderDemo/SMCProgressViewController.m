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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.progressLayer = [SMCProgressLayer layerWithProgressView:self.progressView];

    [self.view.layer addSublayer:self.progressLayer];
}

- (void)viewDidLayoutSubviews
{
    if ((self.parentViewController != nil) && (self.heightLayoutConstaint == nil))
    {
        CGFloat statusBarHeight = self.parentViewController.topLayoutGuide.length;

        self.heightLayoutConstaint = [self.view.heightAnchor constraintEqualToConstant:statusBarHeight];
        self.heightLayoutConstaint.active = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - SMCProgressObserver

- (void)progressProvider:(SMCProgressProvider *)progressProvider didUpdateProgress:(float)progress
{
    [self.progressLayer setProgress:progress animated:YES];
}

- (void)progressProviderDidBecomeActive:(SMCProgressProvider *)provider
{
    [self.progressLayer setProgress:0.0f animated:NO];
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
