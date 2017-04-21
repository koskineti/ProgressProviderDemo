//
//  SMCCircularProgressViewController.m
//  ProgressProviderDemo
//
//  Created by Koskinen, Timo on 19/04/2017.
//  Copyright © 2017 Suunto Oy. All rights reserved.
//

#import "SMCCircularProgressViewController.h"

#import "SMCCircularProgressView.h"
#import "SMCProgressLayer.h"
#import "SMCProgressProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface SMCCircularProgressViewController ()

@property (weak, nonatomic) IBOutlet SMCCircularProgressView *progressView;

@property (nonatomic, readwrite, getter=isPresented) BOOL presented;
@property (nonatomic, weak) SMCProgressProvider *progressProvider;
@property (nonatomic, nullable) SMCProgressLayer *progressLayer;

@end

@implementation SMCCircularProgressViewController

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

    self.progressLayer = [SMCProgressLayer layerWithProgressDisplay:self.progressView];

    [self.view.layer addSublayer:self.progressLayer];

    [self _presentIfNeeded];
}

#pragma mark - SMCProgressObserver

- (void)progressProvider:(SMCProgressProvider *)progressProvider didUpdateProgress:(float)progress
{
    [self.progressLayer setProgress:progress animated:YES];
}

- (void)progressProviderDidBecomeActive:(SMCProgressProvider *)provider
{
    [self.progressLayer setProgress:0.0f animated:NO];
    [self _presentAnimated:YES];
}

- (void)progressProviderDidFinish:(SMCProgressProvider *)provider
{
    [self.progressLayer finish];
    [self _dismissAnimated:YES];
}

- (void)progressProviderDidCancel:(SMCProgressProvider *)provider
{
    [self.progressLayer cancel];
    [self _dismissAnimated:YES];
}

- (void)progressProvider:(SMCProgressProvider *)provider didAddObserver:(id<SMCProgressObserver>)observer
{
    if (observer == self)
    {
        self.progressProvider = provider;
    }
}

- (void)progressProvider:(SMCProgressProvider *)provider didRemoveObserver:(id<SMCProgressObserver>)observer
{
    if (observer == self)
    {
        self.progressProvider = nil;
    }
}

#pragma mark - Private

- (void)_presentIfNeeded
{
    BOOL progressProviderIsActive = ((self.progressProvider != nil) && self.progressProvider.isActive);

    if (progressProviderIsActive)
    {
        float progress = self.progressProvider.progress;

        [self.progressLayer setProgress:progress animated:NO];

        self.view.alpha = 1.0f;
        self.presented = YES;
    }
    else
    {
        self.view.alpha = 0.0f;
        self.presented = NO;
    }
}

- (void)_presentAnimated:(BOOL)animated
{
    if (!self.presented)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.25f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.view.alpha = 1.0f;
            } completion:NULL];
        }
        else
        {
            self.view.alpha = 1.0f;
        }

        self.presented = YES;
    }
}

- (void)_dismissAnimated:(BOOL)animated
{
    if (self.presented)
    {
        if (animated)
        {
            [UIView animateWithDuration:0.25f delay:1.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.view.alpha = 0.0f;
            } completion:NULL];

        }
        else
        {
            self.view.alpha = 0.0f;
        }
        
        self.presented = NO;
    }
}

@end

NS_ASSUME_NONNULL_END
